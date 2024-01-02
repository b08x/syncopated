#!/usr/bin/env bash


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
