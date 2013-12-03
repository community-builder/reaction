# *****************************************************
# product collection
# *****************************************************

# Scope variable import
Shops = @Shops
Products = @Products
Customers = @Customers
Orders = @Orders
Cart  = @Cart

getDomain = (client) ->
  get_http_header(client, 'host').split(':')[0]

Meteor.publish 'shops', ->
  Shops.find domains: getDomain(this)

Meteor.publish 'products', ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Products.find shopId: shop._id

Meteor.publish 'product', (id) ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Products.findOne _id: id, shopId: shop._id

# *****************************************************
# Client access rights for products
# *****************************************************
Products.allow
  insert: (userId, doc) ->
    # the user must be logged in, and the document must be owned by the user
    #return (userId && doc.owner === userId);
    true
  update: (userId, doc, fields, modifier) ->
    # can only change your own documents
    true
    #return doc.owner === userId;
  remove: (userId, doc) ->
    # can only remove your own documents
    doc.owner is userId
  #fetch: ['owner']

# *****************************************************
# orders collection
# *****************************************************

Meteor.publish 'orders', ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Orders.find shopId: shop._id

Meteor.publish 'order', (id) ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Orders.findOne _id: id, shopId: shop._id

# *****************************************************
# Client access rights for orders
# *****************************************************
Orders.allow
  insert: (userId, doc) ->
    # the user must be logged in, and the document must be owned by the user
    #return (userId && doc.owner === userId);
    true
  update: (userId, doc, fields, modifier) ->
    # can only change your own documents
    true
    #return doc.owner === userId;
  remove: (userId, doc) ->
    # can only remove your own documents
    doc.owner is userId
  #fetch: ['owner']


# *****************************************************
# customers collection
# *****************************************************

Meteor.publish 'customers', ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Customers.find shopId: shop._id

Meteor.publish 'customer', (id) ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Customers.findOne _id: id, shopId: shop._id

# *****************************************************
# Client access rights for customers
# *****************************************************
Customers.allow
  insert: (userId, doc) ->
    # the user must be logged in, and the document must be owned by the user
    #return (userId && doc.owner === userId);
    true
  update: (userId, doc, fields, modifier) ->
    # can only change your own documents
    true
    #return doc.owner === userId;
  remove: (userId, doc) ->
    # can only remove your own documents
    doc.owner is userId
  #fetch: ['owner']


# *****************************************************
# cart collection
# *****************************************************

Meteor.publish 'cart', (sessionId) ->
  shop = Shops.findOne domains: getDomain(this)
  if shop
    Cart.find shopId: shop._id, sessionId: sessionId

# *****************************************************
# Client access rights for cart
# *****************************************************
Cart.allow
  insert: (userId, doc) ->
    # the user must be logged in, and the document must be owned by the user
    #return (userId && doc.owner === userId);
    true
  update: (userId, doc, fields, modifier) ->
    # can only change your own documents
    true
    #return doc.owner === userId;
  remove: (userId, doc) ->
    # can only remove your own documents
    doc.owner is userId
  #fetch: ['owner']

Meteor.methods
  addToCart: (cartId,productId,variantData) ->
    now = new Date()
    currentCart = Cart.find({_id: cartId, "items.productId": productId, "items.variants": variantData}).count()
    if currentCart > 0
      Cart.update {_id: cartId, "items.productId": productId, "items.variants": variantData},{ $set: {"items.variants": variantData,updatedAt: now}, $inc: {"items.$.quantity": 1}}
    else
      Cart.update {_id: cartId},{ $addToSet:{items:{productId: productId, quantity: 1, variants: variantData}}}

