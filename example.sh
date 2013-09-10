#start textedit using shortcuts
cliclick  "kd:cmd,space" 
sleep 1
cliclick -m verbose "kd:t,e,x,t,down,return"
sleep 2
#start typing in textedit magically!
for (( c=1; c<=5; c++ ))
do
  cliclick "c:100,200" "kd:h,e,l,l,o,w,o,r,l,d,space" "c:100,240";
done

