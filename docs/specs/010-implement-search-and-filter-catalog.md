## As client 

### 10. Search and filter catalog
**Requirements**
- Client can search/filter products they have access to (via `client_products`) that are `active` and whose brand is `active`.
- Filters include at minimum: brand, product name, price range, status.

**Scenarios**
- Given a client has access to products across multiple brands, when they search with no filters, then all accessible active products are returned.
- Given a client filters by brand name, when they search, then only accessible active products from that brand are returned.
- Given a client filters by a price range, when they search, then only products within that range are returned.
- Given a client has no access to any active products, when they search, then an empty result set is returned (not an error).