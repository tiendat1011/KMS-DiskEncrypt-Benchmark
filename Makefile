# Biến lưu file output

.PHONY: init plan apply output destroy	clean

# Khởi tạo Terraform
init:
	terraform init

# Kiểm tra Plan trước khi Apply
plan:
	terraform plan

# Apply Terraform và lưu output vào file
apply:
	terraform apply -auto-approve

# Xuất output sạch hơn
output:
	terraform output -json > terraform-output.json

# Xóa hạ tầng Terraform
destroy:
	terraform destroy -auto-approve

# Dọn dẹp file output
clean:
	rm terraform-output.json
	rm -r ./ansible/tmp/*.log