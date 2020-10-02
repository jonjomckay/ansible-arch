.PHONY: %

export ANSIBLE_LIBRARY=./modules

%:
	# Create the virtualenv, if it doesn't already exist
	test -d .venv || python3 -m venv .venv

	# Install all the required Python packages
	.venv/bin/pip install -r requirements.txt

	.venv/bin/ansible-playbook -i inventory playbook-$@.yml