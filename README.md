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
git clone git@github.com:meerkat-code/meerkat_drill.git
git clone git@github.com:meerkat-code/meerkat_${COUNTRY}.git
```

### Running country server locally
To run simple nest stack locally for testing/development you can do by:
```
docker-compose -f docker-compose.yml -f postgres.yml up -d
```
You can access the odk at: https://localhost (you need to accept untrusted self-signed development ssl cert there).


### Configuring ODK Aggregate
ODK Aggregate documentation can be found [here](http://docs.opendatakit.org/aggregate-guide/).
Those setting can be changed by updating docker-compose yml config files or `.env` file.

#### Configuring user accounts in ODK Aggregate
Use the ODK Aggregate UI to change admin credentials from `test:aggregate` and set up anonymous data sending.

#### Uploading forms into ODK Aggregate
Use either the graphical interface in ODK Aggregate at <aggregate_root>/formUpload or the API to upload forms to Aggregate.

#### Configuring submission publishing
Using Form Management tab in ODK Aggregate, set up submission publishing with the following parameters:
* Publish to: Z-ALPHA JSON
* Data to Publish: BOTH Upload Existing & Stream New Submission Data
* Url to publish to: http://nest:5000/upload
* Include Media as: Links(URLs) to Media

### Configuring Nginx and SSL certificates
If necessary, install and use [Certbot Auto](https://certbot.eff.org/docs/install.html#certbot-auto) to create SSL certificates for your domain. Make sure the certificates are mapped into Nginx Docker container correctly by setting the environment variables in country-specific docker-compose configuration files in the country configurations repo.

### Configuring Nest
#### SQS queue
A standard SQS queue should be created in AWS with default properties.
#### Configuring hash salt for Nest
Meerkat Nest uses salted hashing to anonymise the data. To make this secure, the hashed fields must be salted before hashing. Nest does this automatically but
you can use a custom salt file by defining the SALT environmental variable in the Nest container.


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
#### Demo country server example
To start services you can run:
```bash
docker-compose -f docker-compose.yml -f postgres.yml logs -f nginx
```
`postgres.yml` is used to use dockerised local database


[Optional] Manual configuration for initial backup is required with:
```bash
docker exec -it db /manual_setup.sh
```
### Using bash helper scripts
1. For convinence create the following symlink
    ```
    # ln -s $(pwd)/bash_utils/country_server_console_wrapper.sh /usr/local/bin/country_server_console_wrapper
    # chmod a+x /usr/local/bin/country_server_console_wrapper
    ```
1. The following args should be passed as env variables
    ```
     USERNAME - name of the user in whom home dir meerkat_country_server is checked out
     COUNTRY_NAME - name of deployed country e.g. car or demo
     ACTION - docker-compose action you'd like to use. e.g. 'up -d', 'stop', 'start', 'rm -v'
     [optional] SERVICE - name of docker service e.g. odk, nest, nginx
    ```
#### Example usage in crontab:
1. Create directory `/home/ec2-user/cron_jobs/`
1. 
    ```
    @reboot USERNAME=ec2-user COUNTRY_NAME=car ACTION='up -d' /usr/local/bin/country_server_console_wrapper  >> /home/ec2-user/cron_jobs/country_server_init.log 2>&1
    ```
#### Helper script for ssl cert reneval
1. Create directory `/home/ec2-user/cron_jobs/`
1. Install certbot-auto and add it in `/usr/local/sbin`
1. Add ssl_renval helper script to **root** crontab 
    ```
    2 30 * * *  USERNAME=ec2-user COUNTRY_NAME=car /home/ec2-user/meerkat_country_server/bash_utils/ssl_reneval.sh >> /home/ec2-user/cron_jobs/ssl_reneval.log 2>&1
    ```
   
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

##### Local storage of backups for Jordan and RMS
I've copied the old config to `env.aws_backup`
```bash
ops@bhs:/etc/wal-e.d$ ls
env  env.aws_backup  gpg_pub.key
```
The new configuration:
```bash
root@bhs:/etc/wal-e.d/env# tail -vn +1 *
==> WALE_FILE_PREFIX <==
file://localhost/backups/pg

==> WALE_GPG_KEY_ID <==
625C3EAEBFBCD66E
```
Together with updates in `nest/country.yml` files in corresponding country configs:
```docker
services:
  db:
    volumes:
      - "/home/ops/pg_backups:/backups/pg"
```
results in storing weekly backups and continuous WAL files locally.

More information in wal-e doc: https://github.com/wal-e/wal-e

#### Encryption
The `gpg_pub.key` is the public gpg key to encrypt data before they are send to S3.
`WALE_GPG_KEY_ID` should point to this key id.

### Logs
Logs for continous WAL backup can be seen id db container logs.
Weekly base backups will be logged inside the container under `/cron.log`


