# Bagit

Minimal SSH git server: **git-shell + push-to-create**. 

Bare repos live under the git user's home (a Docker/Podman volume). 

The git user's login shell is `bgit-shell`, a thin POSIX-sh wrapper that adds
the two things git's server side lacks (auto-create on push, confinement to the
home dir) and then hands every protocol operation to `git-shell`.

## Run

	echo "SSH_AUTHORIZED_KEYS=$(cat ~/.ssh/id_ed25519.pub)" > .env
	# or export directly; can also be multiple.
	docker compose up -d --build

## Use

	git remote add origin ssh://git@host:2222/myrepo.git
	git push origin master          # repo auto-created on first push
	git clone ssh://git@host:2222/myrepo.git

## Notes

- Repo names are a flat namespace: letters, digits, `.`, `_`, `-` only.
- Debug remove stale runs: `ssh-keygen -R '[localhost]:2222'`
