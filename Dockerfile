#Multistage docker

#use ubuntu 18.04 as based image and call it packager
FROM ubuntu:18.04 as packager

#Add shasum.py to for tool to check shasum 
ADD shasum.py /tmp/

#Download litecoin 0.18.1 + litecoin 0.18.1 signatures and compare shasum
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  python3 \
  && curl -fsSL https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz \
  -o /tmp/litecoin.tar.gz \
  && echo $(\
  curl -fsSL https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-linux-signatures.asc | \
  grep litecoin-0.18.1-x86_64-linux-gnu.tar.gz | awk '{print $1}' \
  ) /tmp/litecoin.tar.gz | \
  sha256sum -c --strict - \
  && python3 /tmp/shasum.py \
  && tar -zxvf /tmp/litecoin.tar.gz -C /tmp/


#use ubuntu 18.04 as based image
FROM ubuntu:18.04

#add user litecoin to be container user 
RUN useradd -ms /bin/false -u 1001 -U litecoin

#Copy artifact from packager to this docker layer
COPY --from=packager --chown=litecoin:litecoin /tmp/litecoin-0.18.1/ /home/litecoin/

#use litecoin user as application user
USER litecoin

#use command litecoind to start litecoin
CMD /home/litecoin/bin/litecoind
