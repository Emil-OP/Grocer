Steps to Create a Rest API with PostgreSQL and NodeJS

1) Download and install pgAdmin 
   - https://pgadmin-archive.postgresql.org/pgadmin4/index.html
2) Download and install NodeJS
   - Open Terminal: 'brew update && brew install node'
3) Create VSCode project and install packages within the project
   - Open Terminal in VSCode project: 
      a) 'npm install pg'
      b) 'npm install express'
      c) 'npm install body-parser'
4) In order to test connection an operations
   - Open Terminal in VSCode project: 'node api.js'
   - Visit 'localhost:3300/users' on a browser
        //If pgadmin is running properly and connection is configured to the proper database it should display a list of all
        the rows in the table 'users' in json format