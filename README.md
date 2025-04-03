# README

[![My Skills](https://skillicons.dev/icons?i=ruby,rails,html,css,tailwind,yarn,sqlite,github)](https://skillicons.dev)

<p align="left">
  <img src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/rubygems.png" alt="Rubygems" width="50"/>
  <img src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/jira.png" alt="Jira" width="50"/>
</p>

![CI](https://github.com/cs-muic/smart_edu_team2-deployment-test/actions/workflows/ci.yml/badge.svg) ![Deploy](https://github.com/cs-muic/smart_edu_team2-deployment-test/actions/workflows/deploy.yml/badge.svg)

# [Smart Edu](https://bbb.buggycode.space)

See our web service in action: [https://bbb.buggycode.space](https://bbb.buggycode.space)

## Overview

Smart Edu is a web-based application designed to streamline student management and attendance tracking in educational institutions. The platform includes user authentication, multi-tenancy support, and various administrative features.

## Features

- User authentication (Sign In/Sign Up/Forgot Password)
- Role-based access control (Admin, Teacher, Student)
- Attendance tracking
- Multi-tenancy support
- QR-based check-in system
- Timezone-aware scheduling

## Tech Stack and Development

- **Backend**: Ruby on Rails
- **Frontend**: TailwindCSS, ERB templates
- **Database**: SQLite
- **Deployment**: Kamal, Docker, Github Actions CI/CD
- **Testing**: RSpec, Capybara, Rails
- **Agile**: [Jira](https://hir0yat0.atlassian.net/jira/software/projects/SWEP2/boards/1)
- **Communication**: [Discord](https://discord.gg/rrmamUF3mw)

---

## Setup & Installation

### Prerequisites

Check Gemfile to see which versions of what need to be installed.

- Ruby
- SQLite
- Yarn
- Etc.

Have Docker Desktop installed and ready.

### Installation and local development

```sh
# Clone the remote repository and visit local copy
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

For docker login credentials please contact Top.

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

Note: if you are part of the team, after your PR has been approved and successfuly merged, github actions will deploy automatically if tests have passed.

## Contributing

1. Fork the repository.
2. Create a new feature branch to indicate a feature and log progress on jira
3. Commit changes ([see commit message convention](https://ec.europa.eu/component-library/v1.15.0/eu/docs/conventions/git/))
4. Push to your branch (`git push origin feature-name`).
5. Open a pull request.
6. Wait for approval and make changes if needed.
7. Merge to main after approval

---

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Contact

For communication, please refer to the discord: [Discord](https://discord.gg/rrmamUF3mw)

Agile development management: https://hir0yat0.atlassian.net/jira/software/projects/SWEP2/boards/1
