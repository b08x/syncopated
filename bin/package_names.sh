#!/usr/bin/env bash

# The purpose of the package_names.sh script is to query the Repology API and retrieve metadata about software packages/projects.

# Specifically, it allows filtering packages based on different criteria and retrieving details via API calls to Repology.org.

# Some key things the script allows:

# Searching for packages by name or description substring
# Filtering by maintainer
# Filtering by category
# Checking which repositories a package is present or absent in
# Filtering by number of repositories or repository families a package belongs to
# Checking if a package is up-to-date or outdated in different repositories
# Retrieving full details for a single package by its name
# This allows programmatically interrogating Repology's package database to find packages that match certain criteria, like unique/outdated packages in specific repositories.

# The output is formatted as JSON which makes it easy to parse and consume in other scripts/programs.

# So in summary, the package_names.sh script provides a wrapper and CLI interface to make API queries to the Repology database to retrieve packaged metadata according to different filtering options. This enables automated discovery and auditing of packages.

# Supported filters are:
#
# search
# project name substring to look for
# maintainer
# return projects maintainer by specified person
# category
# return projects with specified category
# inrepo
# return projects present in specified repository
# notinrepo
# return projects absent in specified repository
# repos
# return projects present in specified number of repositories (exact values and open/closed ranges are allowed, e.g. 1, 5-, -5, 2-7
# families
# return projects present in specified number of repository families (for instance, use 1 to get unique projects)
# repos_newest
# return projects which are up to date in specified number of repositories
# families_newest
# return projects which are up to date in specified number of repository families
# newest
# return newest projects only
# outdated
# return outdated projects only
# problematic
# return problematic projects only

# Example: get unique outdated projects not present in FreeBSD maintainer by foo@bar.com
#
# /api/v1/projects/?notinrepo=freebsd&maintainer=foo@bar.com&families=1&outdated=1

curl -s "https://repology.org/api/v1/projects/?inrepo=arcg&search=ambix"|jq

curl -s "https://repology.org/api/v1/project/ambix" | jq
