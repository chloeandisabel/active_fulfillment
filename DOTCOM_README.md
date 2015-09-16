Current status of our Dotcom Distribution integration.

## Summary

For C+I we need to support the following end points:
- Place an order
- Query the order
- Query the shipment for tracking info
- Upload items (SKUs) so that we can place orders for those SKUs
- Upload purchase orders
- Query purchase orders
- Query inventory

See Dotcom's XSDs for the definitive definition of message contents. Their
API doc isn't always up to date.

The options hash is used to set service-specific options. See
http://www.rubydoc.info/gems/active_fulfillment for the API documentation.

## Other information

- This project is MIT licensed.
- Contributions are welcomed! See CONTRIBUTING.md for more information.
