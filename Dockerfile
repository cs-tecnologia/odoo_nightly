#FROM debian:bullseye-slim
FROM python:3.10-slim-bullseye
#FROM debian:buster-slim
#MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8
ENV APT_DEPS='build-essential libldap2-dev libpq-dev libsasl2-dev' \
    PIP_ROOT_USER_ACTION=ignore 

###Criar usuario Odoo
RUN useradd -m -U -r -d /opt/odoo -s /bin/bash odoo &&\
/bin/bash -c "mkdir -p /opt/odoo/{etc,log,addons}" &&\
chown -R odoo:odoo /opt/odoo &&\
mkdir -p /var/lib/odoo && \
chown -R odoo:odoo /var/lib/odoo/

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    wget \
    swig \
    default-jre \
    ure \
    dirmngr \
    fonts-noto-cjk \
    fonts-symbola \
    git \
    gnupg \
    gnupg1 \
    gnupg2 \
    pkg-config \
    ldap-utils \
    libcups2-dev \
    libevent-dev \
    libffi-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    liblcms2-dev \
    libldap2-dev \
    libopenjp2-7-dev \
    libjpeg62-turbo \
    libpng-dev \
    libpq-dev \
    libreoffice-java-common \
    libreoffice-writer \
    libsasl2-dev \
    libsnmp-dev \
    libssl-dev \
    libtiff5-dev \
    libwebp-dev \
    libxcb1-dev \
    libxml2-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt1-dev \
    libzip-dev \
    locales \
    node-clean-css \
    nodejs \ 
    node-less \
    npm \
    openssh-client \
    python3 \
    python3-dev \
    python3-dev nodejs \
    python3-lxml \
    python3-num2words \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pip \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-suds \
    python3-venv \
    python3-vobject \
    python3-watchdog \
    python3-wheel \
    python3-xlrd \
    python3-xlwt \
    texlive-fonts-extra \
    wkhtmltopdf \
    xfonts-75dpi \
    xfonts-base \
    xz-utils \
    zlib1g-dev \
###Dependências de relatórios
    #wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
    #dpkg -i ./wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
    #rm -f wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
    #apt -f install -y        
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \    
    && rm -rf /var/lib/apt/lists/* wkhtmltox_0.12.6.1-2.bullseye_amd64.deb

# install latest postgresql-client
#RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian bullseye)
RUN npm install -g rtlcss

###Instalar dependências do odoo e o odoo
RUN set -x; \
pip3 install -r https://github.com/odoo/odoo/raw/14.0/requirements.txt && \
wget -O - https://nightly.odoo.com/odoo.key | apt-key add - && \
echo "deb http://nightly.odoo.com/14.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list && \
apt update ; apt upgrade -y && \
apt install odoo -y && \
pip3 install pyopenssl --upgrade

RUN set -x; \
        #Educação
        #git clone --depth 1 --branch 14.0 https://github.com/openeducat/openeducat_erp
        #ISP somente 12
        #git clone --depth 1 --branch 14.0 https://github.com/OCA/vertical-isp
        #HelpDesk
        git clone --depth 1 --branch 14.0 https://github.com/OCA/helpdesk /opt/odoo/addons/helpdesk &&\
        #pip3 install -r /opt/odoo/addons/helpdesk/requirements.txt &&\
        #Serviço de campo
        git clone --depth 1 --branch 14.0 https://github.com/OCA/field-service /opt/odoo/addons/field-service &&\
        pip3 install -r  /opt/odoo/addons/field-service/requirements.txt &&\
        #conector telefonia
        #git clone --depth 1 --branch 14.0 https://github.com/OCA/connector-telephony /opt/odoo/addons/l10n-brazil &&\
        #pip3 install -r  /opt/odoo/addons/l10n-brazil/requirements.txt  &&\
        #l10n-brazil
        git clone --depth 1 --branch 14.0 https://github.com/OCA/l10n-brazil /opt/odoo/addons/l10n-brazil &&\
        pip3 install -r  /opt/odoo/addons/l10n-brazil/requirements.txt  &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/currency /opt/odoo/addons/currency &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/bank-payment /opt/odoo/addons/bank-payment &&\
        pip3 install -r  /opt/odoo/addons/bank-payment/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/account-payment /opt/odoo/addons/account-payment &&\
        pip3 install -r  /opt/odoo/addons/account-payment/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/account-invoicing /opt/odoo/addons/account-invoicing &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/account-reconcile  /opt/odoo/addons/account-reconcile &&\
        pip3 install -r  /opt/odoo/addons/account-reconcile/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/mis-builder  /opt/odoo/addons/mis-builder &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/reporting-engine /opt/odoo/addons/reporting-engine &&\
        pip3 install -r  /opt/odoo/addons/reporting-engine/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/server-tools  /opt/odoo/addons/server-tools &&\
        pip3 install -r  /opt/odoo/addons/server-tools/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/queue /opt/odoo/addons/queue &&\
        pip3 install -r  /opt/odoo/addons/queue/requirements.txt &&\
        #git clone --depth 1 --branch 14.0 https://github.com/OCA/web /opt/odoo/addons/web &&\
        #pip3 install -r  /opt/odoo/addons/web/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/contract /opt/odoo/addons/contract &&\
        pip3 install -r  /opt/odoo/addons/contract/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/manufacture /opt/odoo/addons/manufacture &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/account-analytic /opt/odoo/addons/account-analytic &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/stock-logistics-warehouse /opt/odoo/addons/stock-logistics-warehouse &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/server-ux /opt/odoo/addons/server-ux &&\
        pip3 install -r  /opt/odoo/addons/server-ux/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/product-attribute /opt/odoo/addons/product-attribute &&\
        pip3 install -r  /opt/odoo/addons/product-attribute/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/stock-logistics-workflow /opt/odoo/addons/stock-logistics-workflow &&\
        pip3 install -r  /opt/odoo/addons/stock-logistics-workflow/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/purchase-workflow /opt/odoo/addons/purchase-workflow &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/sale-workflow /opt/odoo/addons/sale-workflow &&\
        pip3 install -r  /opt/odoo/addons/sale-workflow/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/delivery-carrier /opt/odoo/addons/delivery-carrier &&\
        pip3 install -r  /opt/odoo/addons/delivery-carrier/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/partner-contact /opt/odoo/addons/partner-contact &&\
        pip3 install -r  /opt/odoo/addons/partner-contact/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/commission /opt/odoo/addons/commission &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/edi /opt/odoo/addons/edi &&\
        pip3 install -r  /opt/odoo/addons/edi/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/community-data-files /opt/odoo/addons/community-data-files &&\
        pip3 install -r  /opt/odoo/addons/community-data-files/requirements.txt &&\
        git clone --depth 1 --branch 14.0 https://github.com/OCA/manufacture-reporting /opt/odoo/addons/manufacture-reporting &&\
        pip install -e git+https://github.com/Engenere/erpbrasil.assinatura@fix-namespaces#egg=erpbrasil.assinatura

# Adicionar localização brasileira
RUN apt-get update -y && apt-get upgrade -y  \
    && apt-get install -y --no-install-recommends ${APT_DEPS} \
    #&& pip install email_validator \   
    #&& pip install signxml==2.9.0 \
    #&& pip install psycopg2 \
    #&& pip install certifi==2022.9.24 \
    #&& pip install pyOpenSSL==20.0.1 \
    #&& pip install signxml==2.9 \
    #&& pip install certifi==2022.9.24 \
    #&& pip install acme==1.32.0 \
    #&& pip install astor==0.8.1 \
    #&& pip install Avalara==22.11.0 \
    #&& pip install bcrypt==4.0.1 \
    #&& pip install cryptography==38.0.3 \
    #&& pip install dataclasses==0.6 \
    #&& pip install dicttoxml==1.7.4 \
    #&& pip install et-xmlfile==1.1.0 \
    #&& pip install josepy==1.13.0 \
    #&& pip install multidict==6.0.2 \
    #&& pip install OdooRPC==0.9.0 \
    #&& pip install openpyxl==3.0.10 \
    #&& pip install openupgradelib==3.3.4 \
    #&& pip install paramiko==2.12.0 \
    #&& pip install phonenumbers==8.13.0 \
    #&& pip install PyMeeus==0.5.11 \
    #&& pip install PyNaCl==1.5.0 \
    #&& pip install pyRFC3339==1.1 \
    #&& pip install pysftp==0.2.9 \
    #&& pip install pytz==2022.6 \
    #&& pip install sentry-sdk==1.11.0 \
    #&& pip install urllib3==1.26.12 \
    #&& pip install yarl==1.8.1 \
    #&& pip install zope.interface==5.5.1 \        
    && pip3 install -r https://raw.githubusercontent.com/OCA/l10n-brazil/14.0/requirements.txt \
    && apt-get -y autoremove  \
    && chown -R odoo:odoo /opt/odoo/addons/

# Set the default config file
COPY ./entrypoint.sh /
COPY ./odoo.conf /opt/odoo/etc/odoo.conf
RUN chown odoo:odoo /opt/odoo/etc/odoo.conf


# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /opt/odoo/etc/odoo.conf
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Mount /opt/odoo/data to allow restoring filestore
VOLUME ["/opt/odoo/addons/"]

# Set default user when running the container
USER odoo

# Start
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
