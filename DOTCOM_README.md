Current status of our DotCom integration

## Summary

As of 8/4/2015 we still do not have a contract with Dotcom.  That limits my ability to test my implementation.

For C+I we need to support the following end points:
1. Place an order
2. Query the order
3. Query the shipment for tracking info
4. Upload items (SKUs) so that we can place orders for those SKUs
5. Query inventory. (These can be deltas using the adjustment endpoint or total counts using the inventory endpoint)

active_fulfillment looks like an early fork of active_shipping. I've made some technology
decisions in this GEM because I saw them used in a more mature iteration of active_shipping.

The methods that a service is required to implement include a signature that doesn't really
translate all that well for Dotcom.  For instance, it would just be easier to change:

```
service.fulfill(order_id, shipping_address, line_items, options = {})
```

to:

```
service.fulfill(options = {})
```

I've included XSDs along with the API doc because the samples in the doc don't necessarily match the schema.
Use the XSD as the authoritative source of the element.

## ActiveModel

active_fulfillment already uses ActiveSupport so I'm including ActiveModel for
validations and object initialization with hash.

## Nokogiri

active_shipping moved away from ReXML to Nokogiri, so I decided to do the same.


The options hash is used to set service-specific options. See http://www.rubydoc.info/gems/active_fulfillment for the API documentation.

## Other information

- This project is MIT licensed.
- Contributions are welcomed! See CONTRIBUTING.md for more information.
