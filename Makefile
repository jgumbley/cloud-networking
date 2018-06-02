define green
	@tput setaf 2; echo $1; tput sgr0;
endef

BASTION_IP=$(shell cd terraform; terraform output bastion_ip)
BASTION_U_H=centos@$(BASTION_IP)

.PHONY: terraform
terraform: deploy_key
	cd terraform; terraform apply -auto-approve
	$(call green,"[All steps successful]")

deploy_key:
	ssh-keygen -t rsa -b 4096 -C "$(shell whoami)@jimssolution" -f ./deploy_key

.PHONY: sshe
sshe:
	ssh -A -i deploy_key $(BASTION_U_H)

.PHONY: sshi
sshi:
	ssh -i ./deploy_key -o "ProxyCommand ssh -W %h:%p -i ./deploy_key $(BASTION_U_H)" centos@10.0.1.56

.PHONY: clean
clean:
	cd terraform; terraform destroy -auto-approve
	$(call green,"[All steps successful]")


