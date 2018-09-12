
=======
dmptool
=======
**This repository is now archived.  Please refer to the subsequent repository https://github.com/CDLUC3/dmptool**
---
**Project moved to Github in June 2014.**

**Helpful information for installing and running DMPTool for your environment:**

DMPTool is a standard database-driven app using Rails v4.x conventions with a few number of dependencies on other tools.  

The application is configured and requires OmniAuth to authenticate to LDAP server and/or a Shibboleth IdP.  In order to use the tool as is, you must configure with one of these 2 authentication providers. 

**Configuration files**  - Required to run the application.  There are template versions of this in the repository.  

* config/database.yml - contains credential information for your database.
* config/shibboleth.yml - contains information for attributes received from shibboleth
* config/ldap.yml - contains credential information for accessing the LDAP servers

**Roles**
There are 6 roles associated with the application which give access to different areas of functionality of the application.

* DMP Admin - super user role - this user has access to all functionality of the application and all roles.
* Institutional Admin - administrator for a particular institution.  Has visibility within a particular institution,  assigns roles to users within their institution and maintains institution information.  Assumes template and resource editor roles. 
* Template editor - user which can create and edit templates
* Resource Editor - user which can create and edit resources for templates providing information specific to their institution.
* Reviewer - can review plans within their institution
* Researcher - default role.  i.e. all users assume this role.  Can create and edit plans

**DMPTool provides 5 main areas of functionality.**

* User  - user maintains profile information
* Institution - information about a particular institution, logo, shibboleth endpoints (optional), contact info.  Maintained by institutional or DMP Admin.  
* DMP Templates - allows template editors ability to create, edit, and copy DMP Templates.  These are the questions that plans are created from. 
* DMP Customizations - allows a resource editor ability to create and edit resouces (links, help text, guidance, example or suggested responses) for particular template
* DMP - data management plans - allows user to create new plans, collaborate with others, print, and export

**Visibility** of information in the tool can be either private, viewable for users within an institution or public (open to everyone).



