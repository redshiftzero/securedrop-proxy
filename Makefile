# Bandit is a static code analysis tool to detect security vulnerabilities in Python applications
# https://wiki.openstack.org/wiki/Security/Projects/Bandit
.PHONY: bandit
bandit: ## Run bandit with medium level excluding test-related folders
	pip install --upgrade pip && \
        pip install --upgrade bandit!=1.6.0 && \
	bandit -ll --recursive . --exclude tests,.venv

.PHONY: safety
safety: ## Runs `safety check` to check python dependencies for vulnerabilities
	pip install --upgrade safety && \
		for req_file in `find . -type f -name '*requirements.txt'`; do \
			echo "Checking file $$req_file" \
			&& safety check --full-report -r $$req_file \
			&& echo -e '\n' \
			|| exit 1; \
		done

.PHONY: update-pip-requirements
update-pip-requirements: ## Updates all Python requirements files via pip-compile.
	pip-compile --generate-hashes --output-file dev-requirements.txt dev-requirements.in requirements.in
	pip-compile --generate-hashes --output-file requirements.txt requirements.in

.PHONY: test
test:
	python -m unittest -v

# Explaination of the below shell command should it ever break.
# 1. Set the field separator to ": ##" and any make targets that might appear between : and ##
# 2. Use sed-like syntax to remove the make targets
# 3. Format the split fields into $$1) the target name (in blue) and $$2) the target descrption
# 4. Pass this file as an arg to awk
# 5. Sort it alphabetically
# 6. Format columns with colon as delimiter.
.PHONY: help
help: ## Print this message and exit.
	@printf "Makefile for developing and testing the SecureDrop proxy.\n"
	@printf "Subcommands:\n\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST) \
		| sort \
		| column -s ':' -t
