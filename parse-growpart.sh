parts=$(getargs growpart=)

if [ ! -z "${parts}" ] ; then
  : > /initqueue/00growpart.sh
fi

for dev in ${parts} ; do
  part=$(echo ${dev} | sed 's/[A-Za-z]//g')
  disk=$(echo ${dev} | sed "s/${part}//g" )
  {
   printf 'gp=$(growpart /dev/%s %s) ; : \n' "${disk}" "${part}"
   printf 'case "${gp}" in\n'
   printf 'NOCHANGE:*|*"does not exist") : ;;\n'
   printf 'CHANGED:*) info "growpart: %s: ${gp}" ;;\n' "${dev}" 
   printf '*) warn "growpart: %s: ${gp}" ;;\n' "${dev}"
   printf 'esac\n'
  } >> /initqueue/00growpart.sh
done

printf ':\n' >> /initqueue/00growpart.sh
