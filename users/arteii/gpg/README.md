# GPG

make sure pinentry is installed

and for nix probably need to append `--pinentry-mode loopback` fix wherever gpg requires a pw
eg:

```
gpg --pinentry-mode loopback --edit-key
```
