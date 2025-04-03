# README

[![My Skills](https://skillicons.dev/icons?i=ruby,rails,html,css,tailwind,yarn,sqlite,github)](https://skillicons.dev)

![image]({https://img.shields.io/badge/Jira-0052CC?style=for-the-badge&logo=Jira&logoColor=white})

![CI](https://github.com/cs-muic/smart_edu_team2-deployment-test/actions/workflows/ci.yml/badge.svg) ![Deploy](https://github.com/cs-muic/smart_edu_team2-deployment-test/actions/workflows/deploy.yml/badge.svg)

# Smart Edu

See our web service in action: https://bbb.buggycode.space/

## Overview

Smart Edu is a web-based application designed to streamline student management and attendance tracking in educational institutions. The platform includes user authentication, multi-tenancy support, and various administrative features.

## Features

- User authentication (Sign In/Sign Up/Forgot Password)
- Role-based access control (Admin, Teacher, Student)
- Attendance tracking
- Multi-tenancy support
- QR-based check-in system
- Timezone-aware scheduling

## Tech Stack

- **Backend**: Ruby on Rails
- **Frontend**: TailwindCSS, ERB templates
- **Database**: PostgreSQL
- **Deployment**: Kamal, Docker
- **Testing**: RSpec, Capybara

---

## Setup & Installation

### Prerequisites

Ensure you have the following installed:

- Ruby (check `.ruby-version` for the required version)
- PostgreSQL
- Node.js & Yarn
- Docker (for deployment with Kamal)

### Installation and local development

```sh
# Clone the repository
git clone https://github.com/Leg-10n/smart_edu_team2.git
cd smart-edu

# Install dependencies
bundle install
yarn install

# Set up database
rails db:create db:migrate db:seed

# Start the development server
rails s
```

### Environment Variables

Create a `.env` file and configure the following:

```
DATABASE_URL=postgres://user:password@localhost:5432/smart_edu
SECRET_KEY_BASE=your_secret_key_here
```

---

## Running Tests

````sh
# Run all tests
rake

## Deployment
### Using Kamal (Docker-based)
```sh
kamal deploy
````

### Traditional Deployment (Capistrano or Manual)

```sh
RAILS_ENV=production rails db:migrate
RAILS_ENV=production bin/rails assets:precompile
```

---

## Contributing

1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature-name`).
3. Commit changes (`git commit -m "Add new feature"`).
4. Push to your branch (`git push origin feature-name`).
5. Open a pull request.

---

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Contact

For support or collaboration, contact **your-email@example.com**.

Agile development management: https://hir0yat0.atlassian.net/jira/software/projects/SWEP2/boards/1
