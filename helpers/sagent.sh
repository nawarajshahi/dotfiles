#!/bin/bash

# Expiration in seconds that the SSH agent will hold on to the keys.
export AGENT_TIMEOUT=14400

function sshagent_findsockets() {
  find ${AGENT_TMPDIR:-/tmp} -uid $(id -u) -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket() {
  if [ ! -x "$(which ssh-add)" ]; then
    echo "ssh-add is not available; agent testing aborted"
    return 1
  fi

  if [ X"$1" != X ]; then
    export SSH_AUTH_SOCK=$1
  fi

  if [ X"$SSH_AUTH_SOCK" = X ]; then
    return 2
  fi

  if [ -f $SSH_AUTH_SOCK ]; then
    echo "$SSH_AUTH_SOCK is completely missing!"
    return 3
  fi

  if [ -S $SSH_AUTH_SOCK ]; then
    ssh-add -l > /dev/null
    if [ $? = 2 ] ; then
      echo "Socket $SSH_AUTH_SOCK is dead! Deleting!"
      rm -f $SSH_AUTH_SOCK
      return 5
    else
      echo "Found ssh-agent socket at: $SSH_AUTH_SOCK"
      return 0
    fi
  else
    echo "$SSH_AUTH_SOCK is not a socket!"
    return 4
  fi
}

function sshagent_init {
  AGENTFOUND=0

  # Attempt to find and use the ssh-agent in the current environment
  if sshagent_testsocket; then AGENTFOUND=1; fi

  # If there is no agent in the environment, search /tmp for possible agents to
  # reuse before starting a fresh ssh-agent process.
  if [ $AGENTFOUND = 0 ]; then
    for agentsocket in $(sshagent_findsockets); do
      if [ $AGENTFOUND != 0 ]; then break; fi
      if sshagent_testsocket $agentsocket; then AGENTFOUND=1; fi
    done
  fi

  # If at this point we still haven't located an agent, it's time to
  # start a new one
  if [ $AGENTFOUND = 0 ]; then
    # TODO: This isn't working
    eval $(ssh-agent -t ${AGENT_TIMEOUT})
  fi

  # Clean up
  unset AGENTFOUND
  unset agentsocket

  # Finally, show what keys are currently in the agent
  ssh-add -l
}

alias sagent="sshagent_init"

