define green
	@tput setaf 2; echo $1; tput sgr0;
endef

.PHONY: terraform
terraform:
	cd terraform; terraform apply -auto-approve
	$(call green,"[All steps successful]")

.PHONY: clean
clean:
	cd terraform; terraform destroy -auto-approve
	$(call green,"[All steps successful]")


