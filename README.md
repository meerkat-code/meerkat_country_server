# Country server data source

This repo helps setting up the source of data for Meerkat Reporting server.
It contains the following projects:
* ODK Aggregate
* Meerkat Nest
* Postgres database used by the two above
* Nginx to glue this together and to provide HTTPS

## Setup

### Cloning source codes and configurations
Set up environment variable `COUNTRY` for the country deployment

Clone the source code for Meerkat nest and the country configuration repository in the same root folder as this repository
```bash
git clone git@github.com:meerkat-code/meerkat_nest.git
git clone git@github.com:meerkat-code/meerkat_${COUNTRY}.git
```

### Configuring ODK Aggregate
ODK Aggregate documentation can be found [here](http://docs.opendatakit.org/aggregate-guide/).

#### Configuring user accounts in ODK Aggregate
Use the ODK Aggregate UI to change admin credentials from `test:aggregate` and set up anonymous data sending.

#### Uploading forms into ODK Aggregate
Use either the graphical interface in ODK Aggregate or the API to upload forms to Aggregate.

#### Configuring submission publishing
Using Form Management tab in ODK Aggregate, set up submission publishing with the following parameters:
* Publish to: Z-ALPHA JSON
* Data to Publish: BOTH Upload Existing & Stream New Submission Data
* Url to publish to: http://nest:5000/upload
* Include Media as: Links(URLs) to Media

### Configuring Nginx and SSL certificates
If necessary, install and use [Certbot](https://certbot.eff.org/) to create SSL certificates for your domain. Make sure the certificates are mapped into Nginx Docker container correctly by setting the environment variables in country-specific docker-compose configuration files in the country configurations repo.

### Configuring hash salt for Nest
Meerkat Nest uses salted hashing to anonymise the data. To make this secure, a salt file must be added. The location of this
salt file is defined in the implementation specific docker-compose file. The sal file can be any file containing UTF-8 text.

### Configuring backups

#### Setting up S3
You need to create a bucket in S3 with reasonable expiration time and the following policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::pgbackup"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": ["arn:aws:s3:::pgbackup/*"]
    }
  ]
}
```
#### Configure wal-e
Create the following configuration in directory `/etc/wal-e.d/`:
```bash
/etc/wal-e.d/
├── env
│   ├── AWS_ACCESS_KEY_ID
│   ├── AWS_REGION
│   ├── AWS_SECRET_ACCESS_KEY
│   ├── WALE_GPG_KEY_ID
│   └── WALE_S3_PREFIX
└── gpg_pub.key

```
With the following ownership and permissions:
```bash
# chown -R 999:docker /etc/wal-e.d
# chmod -R 660 /etc/wal-e.d
# chmod 770 /etc/wal-e.d/env
```
Files inside `/etc/wal-e.d/env` will be used by `envdir` for `wal-e`. Example content:
```bash
root@tsabala:/etc/wal-e.d/env# tail -vn +1 *
==> AWS_ACCESS_KEY_ID <==
AWSKeyId

==> AWS_REGION <==
eu-west-1

==> AWS_SECRET_ACCESS_KEY <==
SeCr#tAW5K3yMeeeeeerkat

==> WALE_GPG_KEY_ID <==
8E2D7335CEC0B46C

==> WALE_S3_PREFIX <==
s3://meerkat-pgbackup
```
More information in wal-e doc: https://github.com/wal-e/wal-e

#### Encryption
The `gpg_pub.key` is the public gpg key to encrypt data before they are send to S3.
`WALE_GPG_KEY_ID` should point to this key id.

### Docker setup

#### Installing Docker and Docker-Compose
Instructions for installing Docker can be found [here](https://docs.docker.com/engine/installation/) and instructions for Docker-Compose [here](https://docs.docker.com/compose/install/).

#### Building Docker images
Build the required Docker images by running
`docker-compose build` in this folder.

## Running the services

### Making sure host system Nginx isn't running
Run `sudo service stop nginx` in the host system to stop it in case it's running.

### Starting docker-compose
To start services you can run:
```bash
docker-compose -f docker-compose.yml -f demo.yml up -d
```
Manual configuration for initial backup is required with:
```bash
docker exec -it db /manual_setup.sh
```

### Logs
Logs for continous WAL backup can be seen id db container logs.
Weekly base backups will be logged inside the container under `/cron.log`


