# Setting up SSL certificate for microweb-apps application

This document describes how to setup SSL certificate for micro-webapps application.

Before continuing with reading, you should read about [Changing webconf-spec configuration](webconf-spec-changing.md).

## Setting up SSL Certificate stored in file

If you have the SSL certificate stored in file accessible from the container, you can simply use `certificate` and `certificate_key` webconf-spec attributes to configure it:

```
{
  "virtualhost": "$mwa_vhost",
  "certificate": "/my/path/to/certificate.crt",
  "certificate_key": "/my/path/to/certificate.key"
}
```

Note that the certificate is always configured for whole virtualhost, so there can be just single configuration with `certificate` and `certificate_key`.

## Setting up SSL certificate stored in the webconf-spec

You can also use webconf-spec to store the certificate data:

```
{
  "virtualhost": "$mwa_vhost",
  "certificate": "-----BEGIN CERTIFICATE-----\nMIIDrDCCApQCCQCicGoQXO+xgDANBgkqhkiG9w0BAQUFADCBlzELMAkGA1UEBhMC\nTkExEDAOBgNVBAgMBzxTVEFURT4xFzAVBgNVBAoMDjxDT01QQU5ZX05BTUU+MQ8w\nDQYDVQQHDAY8Q0lUWT4xEjAQBgNVBAMMCWxvY2FsaG9zdDEaMBgGA1UECwwRPERF\nUEFSVE1FTlRfTkFNRT4xHDAaBgkqhkiG9w0BCQEWDTxBRE1JTl9FTUFJTD4wHhcN\nMTUwNjIyMDczMTU5WhcNMjUwNjE5MDczMTU5WjCBlzELMAkGA1UEBhMCTkExEDAO\nBgNVBAgMBzxTVEFURT4xFzAVBgNVBAoMDjxDT01QQU5ZX05BTUU+MQ8wDQYDVQQH\nDAY8Q0lUWT4xEjAQBgNVBAMMCWxvY2FsaG9zdDEaMBgGA1UECwwRPERFUEFSVE1F\nTlRfTkFNRT4xHDAaBgkqhkiG9w0BCQEWDTxBRE1JTl9FTUFJTD4wggEiMA0GCSqG\nSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0/ORQBAanNyzWd5I/8GZoSCexy0/kfdi8\nWa9gyyvKv4+DYpDYimHCvVQ3eZYtPaxw06QOGUXPSJ2XSGubl2sP5/6q+hGbqPkT\n9nSkEUsHUIq2+BraM0AE2mgysDYj9AgPz+ImlTTGV+IA+/P2b/vxUXmsiy9wiuq3\nafTx2h7PIBOGixI7lVGcx7BcbAlJXkzd7EP2m6E+ZUzzSyW9HUEHJMJF9098LHwi\nLLZR+t5A3aJFP+Fma6H7eFDIhklIt1yAwz0jpq5T85radp6EvrCzy/m9Lc+QZMf0\ngopfWpXKRw1+Az1JnmzlqN5CZVUH8M0SeGaFlsEI1QUDy4U6oErzAgMBAAEwDQYJ\nKoZIhvcNAQEFBQADggEBAHLf2fOE1aZbICnyIG9rNymCC79z/3AyCKyOPMUuntP3\n4F26kxxCcrycXSno8HRUKJHzfDc8R0d3jGdeP4o9pnU1z5+uU76IouOnNB8w0/xT\nb9qRWAfR+dGMxg4GCmec94L6wTb9hIPJCY2cYukcPw5qw/Hx7kIO9vuNnTAo8tJe\nTZrLr3L95HaRDO9s21DrWRbII9cY+icAKJenfNyk/a6I6JEobDIKi3kFWtkICodQ\nCokaPydLVMMOiLfz/GYSg+pDiAB+pzUJl5JafEhlTbwS3XjRIkNNWuMg3whAoLWp\n1TsLT3Ioy5mnxm7tj9t6xpHTKQBj2SvwgL0E6cYZhro=\n-----END CERTIFICATE-----",
  "certificate_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAtPzkUAQGpzcs1neSP/BmaEgnsctP5H3YvFmvYMsryr+Pg2KQ\n2Iphwr1UN3mWLT2scNOkDhlFz0idl0hrm5drD+f+qvoRm6j5E/Z0pBFLB1CKtvga\n2jNABNpoMrA2I/QID8/iJpU0xlfiAPvz9m/78VF5rIsvcIrqt2n08doezyAThosS\nO5VRnMewXGwJSV5M3exD9puhPmVM80slvR1BByTCRfdPfCx8Iiy2UfreQN2iRT/h\nZmuh+3hQyIZJSLdcgMM9I6auU/Oa2naehL6ws8v5vS3PkGTH9IKKX1qVykcNfgM9\nSZ5s5ajeQmVVB/DNEnhmhZbBCNUFA8uFOqBK8wIDAQABAoIBAAL14AYvCqzRijo3\n2nyRQhuSkpOl77idFl5+WRAMQrseRwqvIg9otBCraCVAJ+S1jYyK6bQRVcL+PRWs\naZYx895evRuu23rgWLKq5V2JquCDwMEdbdMD45gwumOZ3kjYRQl9LQXUivhzl47M\nkEEHs+dOnd7kp/H/U7eMVCVgnABnTt+6eSw00AtNClUoYGjrTcUiXNUmEbd/p8DY\nKy6BeYsktwIrfSjzgt7gHencbSY2RzFc9yX0WAi4gj1KQhvwb1QozMadrU45KAD5\nUhE448TeyFDYh69lBJeZq/pcyfb71XrlbpOsG1b0WinBo5pODUQMG8tsJNZvhjwP\nvGu8IoECgYEA14noeLqwCEv5kdCfUlbN9P9Ny10TjTLt/kLkpEynM5Yr1tCte6xF\nas1EwuKLXPWJnHaD/ANQB2T9sb5DYtkNsYpUun1kFfvJar6fvhfANRWvpsByO7nF\nJjGMG6+FN+Om8lpKkypACbFBjjeeb1263uQgkE1z4oLKTLZOIacqTPUCgYEA1vaV\nAuS4VMBOrzcXzZA+gct7nQPS20/qHOXpXXUUm589LpcUfrEs13LCgj8dl5btem43\n8/kzAnP2F+yH0doKUfwh3n2OE5eTr5mc1kQrJEWe6BdG6dOXCbu8Q7GPjqvtXk73\nW4fNbe+zdrPmGE4dMnSzk3cyFziVETzHyAA5R0cCgYAUvGbKHqPK2IxVE+4P/Nvp\noxo342d7IRg2avcWO22mj9791quqB0PSZ5ci7Kqdsd2gWOKPvz3WyEeD7xsKink/\nyGAoZOHZH5UcGOTDZAOQ19pDP6Z9ynyGFSQ2kadOXi90h20/RURN6mi1JvKuIiVV\nRjs/xsPMWeregHd501xFdQKBgQDF8x/ZIEHWWZibpQIYW+ITqAvW1TSQnJCbt+Qk\nGbK2c/blNl67I/CFHbqcMf7QHz3kZibEVhBxC9Psx/Vye3TRdnrB5aC1zflD1RMm\nBHQt3KauVvEIVb5aSjTdqV7nJM9a7yC9etrjh74dayBR9WzRj8Hl4/eOhp5O10ep\nlvsn9QKBgGc8QMXCzMvg60XLx9KW0oebtJXhPv6NVxQzqhkErUHc8BHnIKceCDV0\n4SlNJK+0DST56RWUBv6gB4Mr4W27Q+2aKjbVBEsLSRGuR4guiYoFOGRelkcd4p/N\nqZFjB2cfDTXlnae3v4qxPcETriTY3aDbVvxQ2BjcllX1N/canyCc\n-----END RSA PRIVATE KEY-----"
}
```

To get the string to use for the `certificate` and `certificate_key` attributes from the certificate files, you can use following command:

    $ cat localhost.crt |sed ':a;N;$!ba;s/\n/\\n/g'

## Redirecting from HTTP to HTTPS

If you want to redirect all client from HTTP to HTTPS, you can use following webconf-spec configuration:

```
{
  "virtualhost": "$mwa_vhost",
  "certificate": "/my/path/to/certificate.crt",
  "certificate_key": "/my/path/to/certificate.key",
  "redirects": {
    "/": {
      "to": "https://$mwa_vhost"
    }
  }
}
```
