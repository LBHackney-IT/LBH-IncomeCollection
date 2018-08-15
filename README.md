# Hackney Income Collection Service

# Development

## Installation

1. Install [Docker Community Edition](docker-install)
2. Run `make setup`

[docker-install]: https://docs.docker.com/install/

## Serve the application

```sh
make serve
```

## Run tests

```
make test
```

## Run linter

"Linters" run static analysis on code to ensure it meets style standards. We use [Rubocop](rubocop) on this project with a permissive configuration.

```
make lint
```

[rubocop]: https://github.com/rubocop-hq/rubocop

## Adding gems

1. Add your gem to the Gemfile.
2. Run `make bundle`. This will update the Gemfile.lock, and rebuild the docker image.

# Making changes

1. Follow the instructions in Installation to get set up.
2. Decide with your team on a small slice of work to pick up.
3. Create a branch to work off. Name it appropriately. `git checkout -b my-cool-feature`
4. Develop with TDD!
5. Commit your changes.
6. Check your code style is good and tests are passing using `make check`
7. Make a pull request on the [Github repo](github-repo).
8. Post a link in #team-collection-devs for review.
9. Make any changes if necessary and get another review.
10. Merge into master.
11. Deploy to staging and test manually. Ask someone else to take a look as well, whether they're a developer, user or other team member.
12. Deploy to production!

[github-repo]: https://github.com/LBHackney-IT/LBH-IncomeCollection

# Deployment Pipeline

![Deployment Pipeline](docs/pipeline.png)

1. Log in to CircleCI with Github and connect to the repo.
2. Successful merges to the `master` branch are built automatically by CircleCI.
3. After a successful build, the application is automatically released to [staging](staging).
4. After manually reviewing on staging, when you're happy to release to production, click to permit.
5. The application will be automatically released to [production](production).

The configuration for releasing changes is in `.circleci/config.yml`

[staging]: https://lbhincomecollectionstaging.herokuapp.com/
[production]: https://lbhincomecollectionproduction.herokuapp.com/

# Infrastructure

The staging and production applications are hosted on Heroku. You will need to talk to Rashmi Shetty to get added as a collaborator to the apps.

## Static IP addresses

To communicate with the Hackney API, which is hosted on premises, we need whitelisted static IP addresses for the Heroku instances outbound traffic. They are provided by QuotaGuard Static as a Heroku addon, you can find them in the addon config.

# Notifications

SMS messages are sent using [Gov Notify](gov-notify). Templates are configured there, request access permission from a member of the team. Permitted variables are gathered from a tenancy reference by the application. They include:

- **title** - Title of primary contact, e.g. "Mr."
- **first name** - First name of primary contact, e.g. "Richard"
- **last name** - Surname of primary contact, e.g. "Foster"
- **full name** - Full name with title of primary contact, e.g. "Mr. Richard Foster"
- **formal name** - Formal title and surname of primary contact, e.e. "Mr. Foster"

[gov-notify]: https://www.notifications.service.gov.uk/

While developing, you can include yourself as a false tenancy to test communications by specifying the following environment variables:

```sh
DEVELOPER_TITLE=Miss
DEVELOPER_FIRST_NAME=Test
DEVELOPER_LAST_NAME=User
DEVELOPER_PHONE_NUMBER=01234 567890
DEVELOPER_EMAIL_ADDRESS=test@example.com
```

# Scripts

- **rails stub_data:scheduled_tasks** - Creates scheduled tasks for developer tenancies locally.

# Synchronising Case data

For development purposes, you may need to manually synchronise a case selection.
 - SSH into the AWS instance you're testing against
 - Find the docker ids with `docker ps` - you need the income collection API
 - `docker exec -ti <id> /bin/bash`
 - You can access the rails console with `rails c`

 From here, you can sync **ALL CASES** by creating an instance of DangerousSyncCases, and running `execute` on it.
 This will locally pull all tenancy refs of cases in arrears, generate a priority score for each and save a mapping of ref -> score, band.

 The `my-cases` endpoint currently pulls a sample of these stored mappings, requests the cases from the Tenancy API and returns tenancy list item hashes including score and band.

 In the IC app, you can then:
 - SSH into the instance you're synchronising (local, staging, prod) and enter the rails console
 - Run SyncTenanciesJob.perform_now (occasionally, it will immediately 500, just retry)
 - Currently, this will pull the sample of cases and assign them to user_id 1, so when logging in as user 1, you'll see that list as the Worktray.

# Contacts

- Rashmi Shetty - Development Manager at Hackney (rashmi.shetty@hackney.gov.uk)
- Vladyslav Atamanyuk - Developer at Hackney (vladyslav.atamanyuk@hackney.gov.uk)
- Richard Foster - Lead Developer at [Made Tech](made-tech) (richard@madetech.com)
- Steven Leighton - Developer at [Made Tech](made-tech) (steven@madetech.com)

[made-tech]: https://www.madetech.com/
