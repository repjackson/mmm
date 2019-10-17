# if Meteor.isClient
#     Router.route '/shop', (->
#         @render 'shop_dashboard'
#         ), name:'shop'
#     # Router.route '/shop/:doc_id/view', (->
#     #     @layout 'shop_view_layout'
#     #     @render 'shop_view'
#     #     ), name:'shop_view'
#     # Router.route '/shop/:doc_id/edit', (->
#     #     @layout 'shop_view_layout'
#     #     @render 'shop_edit'
#     #     ), name:'shop_edit'
#
#     Router.route '/products', (->
#         @layout 'mlayout'
#         @render 'products'
#         ), name:'products'
#
#     Router.route "/shop/:doc_id/view", (->
#         @layout 'shop_view_layout'
#         @render 'shop_info'
#         ), name:'shop_view'
#     Router.route "/shop/:doc_id/info", (->
#         @layout 'shop_view_layout'
#         @render 'shop_info'
#         ), name:'shop_info'
#     Router.route "/shop/:doc_id/rentals", (->
#         @layout 'shop_view_layout'
#         @render 'shop_rentals'
#         ), name:'shop_rentals'
#     Router.route "/shop/:doc_id/earnings", (->
#         @layout 'shop_view_layout'
#         @render 'shop_earnings'
#         ), name:'shop_earnings'
#     Router.route "/shop/:doc_id/chat", (->
#         @layout 'shop_view_layout'
#         @render 'shop_chat'
#         ), name:'shop_chat'
#     Router.route "/shop/:doc_id/projections", (->
#         @layout 'shop_view_layout'
#         @render 'shop_projections'
#         ), name:'shop_projections'
#     Router.route "/shop/:doc_id/ads", (->
#         @layout 'shop_view_layout'
#         @render 'product_ads'
#         ), name:'product_ads'
#     Router.route "/shop/:doc_id/tasks", (->
#         @layout 'shop_view_layout'
#         @render 'shop_tasks'
#         ), name:'shop_tasks'
#     Router.route "/shop/:doc_id/stats", (->
#         @layout 'shop_view_layout'
#         @render 'shop_stats'
#         ), name:'shop_stats'
#     Router.route "/shop/:doc_id/edit", (->
#         @render 'shop_edit'
#         ), name:'shop_edit'
#
#
#
#
#
#
#
#
#
#     Template.shop_view_layout.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.shop_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.shop_view_layout.events
#         'click .add_to_cart': ->
#             console.log @
#             Docs.insert
#                 model:'cart_item'
#                 product_id:@_id
#             $('body').toast({
#                 title: "#{@title} added to cart."
#                 # message: 'Please see desk staff for key.'
#                 class : 'green'
#                 # position:'top center'
#                 # className:
#                 #     toast: 'ui massive message'
#                 displayTime: 5000
#                 transition:
#                   showMethod   : 'zoom',
#                   showDuration : 250,
#                   hideMethod   : 'fade',
#                   hideDuration : 250
#                 })
#
#
#
#     Template.product_transactions.onRendered ->
#         Template.children_view.onRendered ->
#             Meteor.setTimeout ->
#                 $('.accordion').accordion()
#             , 1000
#
#     Template.product_transactions.onCreated ->
#         @autorun => Meteor.subscribe 'product_transactions', Router.current().params.doc_id
#     Template.product_transactions.events
#         'click .add_transaction': ->
#             console.log @
#             Docs.insert
#                 model:'transaction'
#                 product_id: @_id
#                 transaction_type:'purchase'
#             Meteor.call 'calculate_product_inventory_amount', @_id
#     Template.product_transactions.helpers
#         product_transactions: ->
#             Docs.find
#                 model:'transaction'
#                 product_id: Router.current().params.doc_id
#
#
#     Template.shop_stats.onCreated ->
#         @autorun => Meteor.subscribe 'shop_stats', Router.current().params.doc_id
#     Template.shop_stats.events
#         'click .advise_price': ->
#             Meteor.call 'advise_price', @_id
#         'click .calculate_transaction_count': ->
#             # console.log @
#             Meteor.call 'calculate_product_inventory_amount', @_id
#     Template.shop_stats.helpers
#         product_transactions: ->
#             Docs.find
#                 model:'transaction'
#                 product_id: Router.current().params.doc_id
#
#
#
#     Template.product_ads.onCreated ->
#         @autorun => Meteor.subscribe 'product_ads', Router.current().params.doc_id
#     Template.product_ads.events
#         'click .create_product_ad': ->
#             Docs.insert
#                 model:'product_ad'
#                 product_id:Router.current().params.doc_id
#             Meteor.call 'advise_price', @_id
#         'click .calculate_transaction_count': ->
#             # console.log @
#             Meteor.call 'calculate_product_inventory_amount', @_id
#     Template.product_ads.helpers
#         product_transactions: ->
#             Docs.find
#                 model:'transaction'
#                 product_id: Router.current().params.doc_id
