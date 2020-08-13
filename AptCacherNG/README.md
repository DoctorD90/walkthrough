# Apt-Cacher-NG

## Introduction
Install apt-cache-ng to cache packages for Debian's apt-tool (Ubuntu too).

## Steps
### Preparations
Install the required software
```
sudo apt-get update
sudo apt-get install apt-cacher-ng
```

### Operations
#### Server Machine
Setup a static IP address on server machine; in this guide I will use *192.168.1.100*.

If you want you can use my minimal `acng.conf` file
```
sudo cp ./cfg/acng.conf /etc/apt-cacher-ng/acng.conf
```
You'd like to custom the settings below:
- *CacheDir*: where packages will be stored
- *Port*: the port on which the cacher will listen

In case you will change path settings like `CacheDir`, remember to change the ownership and permissions
```
sudo chown -R apt-cacher-ng:apt-cacher-ng /path/to/folder
sudo chmod -R 2755 /path/to/folder
```
To add a login to the acng-report's functions, edit `/etc/apt-cacher-ng/security.conf`
```
sudo chmod 666 /etc/apt-cacher-ng/security.conf
sudo echo "AdminAuth: Username:Password" >> /etc/apt-cacher-ng/security.conf
sudo chmod 640 /etc/apt-cacher-ng/security.conf
```
Once everything is done, check that *apt-cacher-ng* is configured to start up on boot
```
sudo systemctl is-enabled apt-cacher-ng
```
If it is not
```
sudo systemctl enable apt-cacher-ng
```
And restart it
```
sudo systemctl restart apt-cacher-ng
```

#### Client Machine
Based on your apt-cache-ng network configurations:
- Edit *line 23* in `detect-http-proxy`: set yours apt-proxies' IPs and ports in the format IP:PORT;
- Edit *line 3-4* in `00aptproxy`: set yours apt-proxies' IPs and ports in the format IP:PORT (even if they are commented);

I used the *Server Machine*'s IP with the default apt-cacher-ng's port: `192.168.1.100:3142`.

Copy scripts from `cfg/` folder to the apt's folder
```
sudo cp ./cfg/detect-http-proxy /etc/apt/detect-http-proxy
sudo chmod 755 /etc/apt/detect-http-proxy
sudo cp ./cfg/00aptproxy /etc/apt/apt.conf.d/00aptproxy
sudo chmod 755 /etc/apt/apt.conf.d/00aptproxy
```
Now when you'll run the `apt-get update` or `apt update` commands, you will see
```
...
Proxy that will be used: http://192.168.1.100:3142
...
```
or in case of issues contacting the apt proxy server
```
...
No proxy will be used
...
```

## References
1. [Apt-Cacher-NG Debian Wiki](https://wiki.debian.org/AptCacherNg)
2. [Apt-Cacher-NG Italian Guide](http://guide.debianizzati.org/index.php/APT-Cacher_NG)
3. [How to change the directory of the apt-cacher-ng downloaded packages](https://www.zyxware.com/articles/3733/how-to-change-the-directory-of-the-apt-cacher-ng-downloaded-packages)
4. [How to Setup APT-Caching Server Using Apt-Cacher NG on Ubuntu 18.04](https://kifarunix.com/how-to-setup-apt-caching-server-using-apt-cacher-ng-on-ubuntu-18-04/)
5. [How do I ignore a proxy if not available?](https://askubuntu.com/questions/53443/how-do-i-ignore-a-proxy-if-not-available)
