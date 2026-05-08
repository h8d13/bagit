# Bgit

SSH-jail git server in a docker container. Forced-command authorized_keys runs `bgit-jail` (whitelist: `git-upload-pack`, `git-receive-pack`, `git-upload-archive`, plus `bgit-list`/`bgit-init`/`bgit-rm`). Bare repos live under `/data` (volume).

Build:

	docker build -t bgit .

Run:

	docker run -d --name bgit -p 2222:22 -v bgit-data:/data \
	    -e SSH_AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" bgit

Use:

	ssh -p 2222 git@host bgit-init repo "description"
	git remote add origin ssh://git@host:2222/repo
	git push origin master

