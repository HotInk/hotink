# Hot Ink

**Hot Ink** is a RESTful, cross-media, content management and distribution pplatform created by [CUP](http://www.cup.ca) and [Campus Plus](http://www.campusplus.com) 
to facilitate online publishing and content distribution for campus newspapers or other small publishers.

**Hot Ink** handles data upload, storage and organization. It will include all the necessary interface components for posting new content, editing of existing content, 
searching for specific content, user authentication and authorization, and publisher account management. Additional functionality, such as web-publishing, content 
sharing and email distribution will be handled by separate applications that interface with **Hot Ink** using an easy-to-use extension interface.

**Hot Ink** will make it possible for other content management systems to easily and RESTfully post their content to **Hot Ink** (and the CUP newswire) using a 
clear API. As well, papers wishing to use **Hot Ink** as a data storage and management application are free to build their own view applications around the API, 
allowing developers the freedom to focus on developing a customized view application while avoiding low-level concerns like database, filesystem and user authentication management.

Volunteers interested in getting involved in the development of the system are encouraged to create a branch and begin working. After database config, this applciation 
should work fine for testing and development purposes. 

**KEEP IN MIND**: This project is still under development and NOT ready for general use. Hang in there, though. The first public release should be arriving **May <del>10th</del>20th**.

## HotInk Publisher

[HotInk Publisher](http://github.com/HotInk/hotink-publisher) is a publishing system designed for newspapers that will fetch and display content from **Hot Ink**. 