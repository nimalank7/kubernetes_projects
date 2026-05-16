# Open Policy Agent (OPA)

Install OPA

```
brew install opa
```

## Evaluates a policy at the command line

`input.json` is the data that OPA uses to evaluate against the policy defined in `example.rego`. The 
`public_servers` is a set that is formed by the policy.

```
./opa eval -i input.json -d example.rego "data.example.violation[x]"
```

`busybox` violates the policy by providing `telnet`
`ci` violates the policy of a public server providing `http`.

`data.example.violation` comes from the API (e.g. `curl localhost:8181/v1/data/example/violation`)