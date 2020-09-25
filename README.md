# Hackney Income Collection - Manage Arrears Frontend

This application provides the user interface for Income Collection officers to manage arrears of
various tenancy types.

Data is provided to this application via API calls to various services:

* [Income API](https://github.com/LBHackney-IT/lbh-income-api)
* [Tenancy API](https://github.com/LBHackney-IT/LBHTenancyAPI)

There are two continuously running services:
* [Production](https://managearrears.hackney.gov.uk/)
* [Staging](https://staging.managearrears.hackney.gov.uk/) - Basic Auth credentials are required.

# Authentication / Authorization

Users log in using their Hackney Google Account.

In order to access parts of the system, the user must be in one of the following groups:

* `managearrears-income-collection-read-write-production` - Rents Team
* `managearrears-leasehold-read-write-production` - Leasehold Team

To have an existing Hackney user added to the relevant group, contact one of the active maintainers on the contacts list below.

# Technology

This application is built using [Ruby on Rails](https://rubyonrails.org/) and hosted in Heroku.

It has no persistence as it communicates directly with other APIs within Hackney.

It uses [Hackney Google SSO](https://github.com/LBHackney-IT/LBH-Google-auth) for authentication.

It uses [GOV.UK Notify](https://www.notifications.service.gov.uk/) to send SMS.

# Design

The app follows the GOV.UK Design System and used the [apltha gov elements gem](https://govuk-elements.herokuapp.com/)

# Development

See the [Development Guide](./docs/development).

# Releasing

See the [Releasing Guide](./docs/development/Releasing.md)

# Contributing

See the [Contributing Guide](./CONTRIBUTING.md).

# Contacts

## Active Maintainers
- **Rashmi Shetty**, Development Manager at London Borough of Hackney (rashmi.shetty@hackney.gov.uk)
- **Miles Alford**, Engineer at London Borough of Hackney (miles.alford@hackney.gov.uk)

## Other Contacts
- **Antony O'Neill**, Lead Engineer at [Made Tech][made-tech] (antony.oneill@madetech.com)
- **Elena Vilimaitė**, Engineer at [Made Tech][made-tech] (elena@madetech.com)
- **Csaba Gyorfi**, Engineer at [Made Tech][made-tech] (csaba@madetech.com)
- **Ninamma Rai**, Engineer at [Made Tech][made-tech] (ninamma@madetech.com)
- **Soraya Clarke**, Relationship Manager at London Borough of Hackney (soraya.clarke@hackney.gov.uk)

[made-tech]: https://www.madetech.com/
