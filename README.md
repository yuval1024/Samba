WMIC code
=========

Based on OpenVAS SAMBA code - http://www.openvas.org/download/wmi/.

Several bug fixes to allow Kerberos authetication.

<b>Important notes:</b>
-----------------------
* Code do not include OpenVAS patches.

* Usage breaks authetication in connect level, thus [sign] is mandatory in order to work.



Usage example:

wmic -k 1 server.acme.com[sign] "select * from Win32_ComputerSystem"


