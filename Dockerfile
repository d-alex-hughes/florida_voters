FROM

ARG RSTUDIO_VERSION
#ENV RSTUDIO_VERSION=${RSTUDIO_VERSION:-1.2.5033}
ARG S6_VERSION
ARG PANDOC_TEMPLATES_VERSION
ENV S6_VERSION=${S6_VERSION:-v1.21.7.0}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV PATH=/usr/lib/rstudio-server/bin:$PATH
ENV PANDOC_TEMPLATES_VERSION=${PANDOC_TEMPLATES_VERSION:-2.9}

RUN apt-get update \ 
  && apt-get install -y --no-install-recommends \ 
    zlib1g-dev \ 
    install2.r -e curl RCurl R.utils data.table stargazer lfe 

EXPOSE 8787

COPY . .

## automatically link a shared volume for kitematic users
VOLUME /home/rstudio/kitematic

CMD ["/init"]