FROM public.ecr.aws/amazonlinux/amazonlinux:latest

WORKDIR /app

# default python3 is available on amazonlinux latest
RUN yum upgrade -y && yum install -y python3 python3-pip
RUN pip install setuptools wheel

RUN python3 -m pip install dbt-core dbt-postgres

# Run dbt deps to install project-specific packages
COPY packages.yml ./
RUN dbt deps

# Copy your dbt project directory
COPY . .

# Command to run dbt commands
ENTRYPOINT [ "dbt", "run" ]

# pass run date as argument for cmd during execution

