+++
author = "Cyb3r Jak3"
title = "VMware vCenter CA"
date = "2019-04-20"
tags = [
    "Tutorial",
    "School",
    "VMware"
]
categories = [
    "Tutorial",
    "School",
    "VMware"
]
aliases = ["vmware-ca"]
thumbnail = "title.webp"
usePageBundles = true
+++

This semester I took a class on Enterprise Virtualization which focused on VMware. For our final, each student had to come up with a project idea and I choose using certificates with vCenter and I thought I would share my documentation.  

---
Servers Required:

- ADDS Server
- ADCS Server
- ESXI
- vCenter

#### 1. Set up domain services for your domain

This is installing Active Directory Domain Services and promoting the domain controller. The domain I used in this was jake.lab.  
&nbsp;  

#### 2. Set up Certificate Services with a Subordinate CA

I used Active Directory Certificate Service (ADCS), it is easy to set up and comes with windows.  
When installing ADCS install the enrollment policy web service. This allows for easier enrollment of certificates. You can remove this feature after certificates have been issued.
![ADCS Install Services](adcs.webp)  
&nbsp;  

#### 3. Setting up vCenter

Next, deploy your vCenter Server. Make the SSO domain vsphere.local or anything as long as it is not your active directory domain.  
Once the install has completed go to `vCenter.<your.domain>:5480` and enable ssh.  

![vCenter SSH Enable](vCenterSSH.webp)  
Now ssh into your vCenter server.
To make things easier, change the root shell to bash using `chsh -s /bin/bash`. This allows us to sftp the files back and forth.

Run the VMware ca certificate tool  

![VMware Certificate Tool Main Menu](certificatetool1.webp)
We want to select option 2.  
You can go through setting up your certificate with the correct options.  

![VMware Certificate Tool Selection](certificatetool2.webp)  
We want to generate Certificates Signing Requests so option 1
Once we have the CSR are we can sftp into the vCenter box and pull that CSR to the windows box to get signed.  
![VMware Cert Transfer](certificatetransfer.webp)
Now with that CSR open up a web browser and go to `https://<CAServer.your.domain>/certsrv` and request a certificate (Open it with notepad and copy the contents). You want to submit an advanced certificate request and make the certificate Template “Subordinate Certification Authority”  

![CA Submit](submitca.webp)
After it is submitted, download the certificate chain.
You want to verify that everything is correct by right-clicking the downloaded chain and selecting open. You should see two certificates.
![Completed Certs](completedcerts.webp)  
You want to export both these certificates by right-clicking each one -> all tasks -> export  
  
You should end up with something like the following. In this example, the chain certificate is the certnew.p7b, the ca cert is cacert.cer, and the issued cert is vCenter.cer.
![Exported Certs](downloadedcerts.webp)  
vCenter does not allow for adding the root cert separately so we have to combine the cacert and the vCenter cert. To do this create a new file in notepad and paste the issued cert (vCenter.cer) followed by the root cert. So you should have two sections of ----BEGIN CERTIFICATE---- and ----END CERTIFICATE----  

![Example Cert](notepadcerts.webp)  

Save this file as vCenterChain.crt and move it back to the vCenter.
Then go back to the ssh session and choose option 1 and enter the correct paths.
![Certificate Import](importedcerts.webp)  
It will now update all the services with new certificates issues by vmca. This bit can take some time.
Once has completed you will be able to browse to your vCenter web page and it will not have a warning and you can see the certificate path.
![Good vCenter Cert](goodvcenter.webp)

#### 4. Issuing Certificate for ESXI

To generate a certificate for an esxi host go to host and clusters and select the host that you want to generate a certificate for then under Configure -> System -> Certificate click “Refresh CA Certificates” then click renew and you should be able to browse to your ESXI Server and see a valid cert.
![Good ESXI Cert](goodesxi.webp)

**Gotcha Moment:** If you get an error that says “Signed certificate could not be retrieved due to a start time error” This is because vCenter does not use the certificate that has not been valid for less than 24 hours. To fix this you can either wait 24 hours or in hosts and cluster and choose the vCenter server. Then Configure -> Advanced Settings and look for the one called `vpxd.certmgmt.certs.minutesBefore` and change it to 10 minutes. You should now be able to renew.  
[Link to Knowledge Base Article](https://kb.vmware.com/s/article/2123386)

#### 5. Clean Up

Once you have issues the certificates, it is a good idea to clean up and re-lock down your domain. It is a couple easy things for clean up.  

1. Disabling SSH on your vCenter Server. You can do this the same way that you enabled it.  
2. Removing ADCS Web Enrollment. You can leave the Web Service one but Web Enrollment is no longer needed. This is good to remove because it makes it easy to issue certificates and could be abused.

---

#### Summary

Overall, I found this project a lot easier than I thought it would be. VMware CA built into vCenter makes management a lot easier. The first way that I did was just by changing the SSL certificate on my ESXI host and machine SSL certificate on vCenter. When an ESXI server is managed by a vCenter instance, you lose the ability to manage the certificates on it. It gets a new certificate that is issued by the VMCA Root Certificate so even if you had a valid certificate, it gets wiped out when managed by vCenter. Once VMCA has a custom root cert, it is easy to get new certificates out to all the services managed in your domain. So if you were going to set up certificates for your VMware vSphere than taking the extra time to set it up as a valid domain Certificate Authority is worth it.
