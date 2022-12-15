FROM debian:bullseye-slim
#FROM debian:buster-slim
#MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    #&& curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    #&& curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases//download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    #&& echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    #&& apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    #&& rm -rf /var/lib/apt/lists/* wkhtmltox.deb
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

# Install Odoo
ENV ODOO_VERSION 14.0
ARG ODOO_RELEASE=20221202
ARG ODOO_SHA=41a75eecbf06b0adfc5537a476e406d28557f938
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Adicionar localização brasileira
RUN apt-get update -y && apt-get upgrade -y  \
    && apt-get install -y --no-install-recommends ${APT_DEPS} \
    && pip install pyOpenSSL==20.0.1 \
    && pip install signxml==2.9 \
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
    && apt-get -y autoremove 

RUN set -x; \
        git clone -b 14.0 --depth 1 https://github.com/OCA/l10n-brazil.git /mnt/extra-addons/l10n-brazil &&\
        pip3 install -r /mnt/extra-addons/l10n-brazil/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-invoicing.git /mnt/extra-addons/account-invoicing &&\
        pip3 install -r opt/odoo/additional_addons/account-invoicing/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-payment.git /mnt/extra-addons/account-payment &&\
        pip3 install -r /mnt/extra-addons/account-payment/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/bank-payment.git  /mnt/extra-addons/bank-payment &&\
        pip3 install -r /mnt/extra-addons/bank-payment/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/delivery-carrier.git  /mnt/extra-addons/delivery-carrier  &&\
        pip3 install -r /mnt/extra-addons/delivery-carrier/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/mis-builder.git  /mnt/extra-addons/mis-builder &&\
        #pip3 install -r /mnt/extra-addons/mis-builder/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/stock-logistics-workflow.git   /mnt/extra-addons/stock-logistics-workflow   &&\
        pip3 install -r /mnt/extra-addons/stock-logistics-workflow/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/account-reconcile.git   /mnt/extra-addons/account-reconcile  &&\
        pip3 install -r /mnt/extra-addons/account-reconcile/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/currency.git   /mnt/extra-addons/currency  &&\
        #pip3 install -r /mnt/extra-addons/currency/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/purchase-workflow.git   /mnt/extra-addons/purchase-workflow  &&\
        #pip3 install -r /mnt/extra-addons/purchase-workflow/requirements.txt &&\
		#
        git clone -b 14.0 --depth 1 https://github.com/OCA/sale-workflow.git   /mnt/extra-addons/sale-workflow   &&\
        pip3 install -r /mnt/extra-addons/sale-workflow/requirements.txt 
        
# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
