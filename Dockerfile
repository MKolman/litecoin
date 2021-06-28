# Multistage docker

# First stage installs dependencies, downloads litecoin
# package, verifies shasum and unpacks it.
FROM ubuntu:20.04 as packager

# Add shasum.py and package signature file to check shasum 
ADD shasum.py /tmp/
ADD litecoin-0.18.1-linux-signatures.asc /tmp/litecoin-signatures.asc

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl ca-certificates python3 \
  && curl -fsSL https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz \
  -o /tmp/litecoin.tar.gz \
  && echo $( \
    grep x86_64-linux-gnu.tar.gz /tmp/litecoin-signatures.asc | awk '{print $1}' \
  ) /tmp/litecoin.tar.gz | \
  sha256sum -c --strict - \
  && python3 /tmp/shasum.py \
  && tar -zxvf /tmp/litecoin.tar.gz -C /tmp/


# Base image copies litecoin files and runs daemon as user `litecoin`
FROM ubuntu:20.04

# Add user litecoin to be container user 
RUN useradd -ms /bin/false -u 1001 -U litecoin

# Copy artifact from packager to this docker layer
COPY --from=packager --chown=litecoin:litecoin /tmp/litecoin-0.18.1/ /home/litecoin/

# Use litecoin user as application user
USER litecoin

# Use command litecoind to start litecoin
CMD /home/litecoin/bin/litecoind
