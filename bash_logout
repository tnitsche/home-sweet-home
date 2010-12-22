# ~/.bash_logout#

# shutdown ssh-agent if running
if [ x"$SSH_AGENT_PID" != x"" ] ; then
  ssh-agent -k
fi


