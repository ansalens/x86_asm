## Connect to protostar via ssh

```sh
ssh -oHostKeyAlgorithms=+ssh-rsa user@<IP>
```

- Or add the following in `~/.ssh/config`:

```
Host protostar
  HostName <IP>
  HostKeyAlgorithms=+ssh-rsa
```

- Then just do: `ssh user@protostar`

#### Source

1. https://askubuntu.com/questions/836048/ssh-returns-no-matching-host-key-type-found-their-offer-ssh-dss
