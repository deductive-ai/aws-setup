package main

import (
	"fmt"
	"log"
	"os"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/zclconf/go-cty/cty"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage: go run backend-toggle.go <file> <mode>")
		fmt.Println("  file: path to providers.tf")
		fmt.Println("  mode: 'local' or 's3'")
		os.Exit(1)
	}

	filename := os.Args[1]
	mode := os.Args[2]

	if mode != "local" && mode != "s3" {
		log.Fatal("Mode must be 'local' or 's3'")
	}

	// Read the file
	content, err := os.ReadFile(filename)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Parse the file
	file, diags := hclwrite.ParseConfig(content, filename, hcl.Pos{Line: 1, Column: 1})
	if diags.HasErrors() {
		log.Fatalf("Error parsing HCL: %v", diags)
	}

	// Find the terraform block
	terraformBlock := file.Body().FirstMatchingBlock("terraform", nil)
	if terraformBlock == nil {
		log.Fatal("No terraform block found")
	}

	// Remove existing backend block if any (backend blocks can have labels like "s3")
	for _, block := range terraformBlock.Body().Blocks() {
		if block.Type() == "backend" {
			terraformBlock.Body().RemoveBlock(block)
			fmt.Println("Removed existing backend block")
			break
		}
	}

	// Add backend block based on mode
	if mode == "s3" {
		s3Block := terraformBlock.Body().AppendNewBlock("backend", []string{"s3"})
		s3Block.Body().SetAttributeValue("bucket", cty.StringVal("deductive-ai-iac"))
		s3Block.Body().SetAttributeValue("key", cty.StringVal("terraform.tfstate"))
		s3Block.Body().SetAttributeValue("region", cty.StringVal("us-west-1"))
		s3Block.Body().SetAttributeValue("encrypt", cty.BoolVal(true))
		fmt.Println("Switched to S3 backend")
	} else {
		fmt.Println("Switched to local backend")
	}

	// Write the file back
	err = os.WriteFile(filename, file.Bytes(), 0644)
	if err != nil {
		log.Fatalf("Error writing file: %v", err)
	}

	fmt.Printf("Successfully updated %s for %s backend\n", filename, mode)
}
