# Linux-Journey
This is the document on using Linux and a self taught on Ethical hacking

># How to install SSH in kali linux

1).Install SSH package by the command:
```
$ sudo apt-get install ssh
```
2).Start the SSH service by the command on localhost default port 22 (-p 22):
```
$ sudo service ssh start
```

>#Enable Kali Linux Remote SSH service
1).Make sure to remove the run level by entering remoce command.
```
$ sudo update-rc.d -f ssh remove
```
2).Load SSH defaults
```
$ sudo update-rc.d -f ssh defaults
```
3).Try checking is the service running.
```
sudo chkconfig ssh
```
4).To check more configuration setting try install ***chkconfig***
```
$ sudo apt-get install chkconfig
```
5).Run ***chkconfig*** to check more option
```
$ sudo chkconfig -l ssh
*or*
$ sudo chkconfig -l
```

># To avoid MITM (Man in The Middle) Attack we need to change the default SSH Keys
Every Kali Linux system installed has a chance of a MITM (Man In The Middle) attack. MITM attacks are usually observed in a client-server environment. A MITM attack occurs when a hacker gets in between these two components. Hackers can take advantage of unencrypted communication through the MITM attack and can listen in on all of your traffic. To avoid MITM attacks, you can follow the below procedure.
Learn more: [linuxhint](https://linuxhint.com/enable_ssh_kali_linux/)

**The first step is to move Kali SSH keys to a new folder**
```
$ sudo cd /etc/ssh/
```
![image](https://user-images.githubusercontent.com/68323176/189156369-faec4ade-a787-43ce-b117-3303d3cdf5f7.png)

```
$ kali@kali: /etc/ssh# mkdir default_kali_keys
```
![image](https://user-images.githubusercontent.com/68323176/189156440-683c5fcd-0cc9-4c74-8597-119ca7393f19.png)

```
$ kali@kali: /etc/ssh# mv ssh_host_* default_kali_keys/
```
![image](https://user-images.githubusercontent.com/68323176/189156554-f7a919a2-1bad-41d9-8e44-de44218cbbd5.png)

**The second step is to regenerate the key**
```
@kali: /etc/ssh# dpkg-reconfigure openssh-server
```
![image](https://user-images.githubusercontent.com/68323176/189157092-bd0f8b3c-ef4e-4c3d-99c8-9c2c4d4a7dce.png)

**The third step is to verify that the SSH key hashes are different. Enter the following command for verification.**
```
$ kali@kali: /etc/ssh# md5sum ssh_host_*
```
![image](https://user-images.githubusercontent.com/68323176/189157265-9bc42dd5-921a-492c-ac97-1e8122d4e6dc.png)
Now, compare the hashes.
```
$ kali@kali: /etc/ssh# cd default_kali_keys/
```
![image](https://user-images.githubusercontent.com/68323176/189157406-5e46da6d-3282-4868-9119-dd32147e4fb5.png)
```
$ kali@kali: /etc/ssh/default_kali_keys# md5sum *
```
![image](https://user-images.githubusercontent.com/68323176/189157500-4217ab21-f1ed-4cfd-a7a5-f07115d1550f.png)

**Finally, enter the following command code to restart the SSH.**
```
$ kali@kali: /etc/ssh/default_kali_keys# service ssh restart
```






