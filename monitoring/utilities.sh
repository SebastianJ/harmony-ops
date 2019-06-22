pssh -i -h <(cut -d' ' -f1 distribution_config.txt) -x '-i 1 -i 2 -i 3 -i 4 -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' -l ec2-user "tac ../tmp_log/*/* | grep Signers | python -c \
  $'import time, datetime, collections, sys, json; a = collections.Counter(); t0 = int(sys.argv[1]) - 60*60\nfor x in sys.stdin:\n s = json.loads(x); t = datetime.datetime.strptime(s[\"t\"][:-4], \"%Y-%m-%dT%H:%M:%S.%f\")\n if time.mktime(t.timetuple()) < t0:\n  break\n a.update(s.get(\"Signers\", "[]").replace(\"[\",\"\").replace(\"]\",\"\").split())\nfor x, y in a.items():\n print x, y' $time0" > hour1

curl -sL https://harmony.one/fn-keys | grep Address: | cut -d'"' -f4 > fn
< fn xargs -P20 -i{} bash -c './wallet.sh balances -address={} | tail -n +2 | grep -v ":  0.0000," | tr -d "\n" | awk -F"[ :,]" "{print \$3, \$11, \$14}"' | awk '$3' > fn-balances
{ echo -n account-key shard one-hour-blocks-signed total-balances [`TZ=America/Los_Angeles date`] ''
  python -c $'import collections, sys; s = {x.rstrip() for x in open("fn")}; b = {a:(b, float(c)) for x in open("fn-balances") for a,b,c in [x.split()]}; c = collections.Counter({x:0 for x in s})\nfor x in sys.stdin:\n a = x.split()\n if a[0] in s:\n  c[a[0]] += int(a[1])\nr = sum(1 for x in c if c[x]); print "%d/%d = %.2f%%" % (r, len(s), 100*r/len(s)); print\nfor x, y in c.most_common(): u, v = b.get(x, ("-", 0)); print "%s %s %8d %10.1f" % (x, u, y, v)' < hour1
} > hour2