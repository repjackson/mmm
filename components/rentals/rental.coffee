# if Meteor.isClient
#     Router.route '/rentals', (->
#         @render 'rentals'
#         ), name:'rentals'
#     # Router.route '/rental/:doc_id/view', (->
#     #     @render 'rental_view_info'
#     #     ), name:'rental_view'
#
#
#
#     Template.rental_view_layout.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.rental_edit_layout.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.rentals.onCreated ->
#         @autorun -> Meteor.subscribe 'rental_docs', selected_rental_tags.array()
#         # @autorun => Meteor.subscribe 'model_docs','reservation'
#         # @autorun => Meteor.subscribe 'model_docs','reservation_slot'
#         # @autorun -> Meteor.subscribe 'shop'
#         # @autorun -> Meteor.subscribe 'model_docs', 'reservation_slot'
#         # @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'shop'
#
#     Template.rentals.onRendered ->
#         Meteor.setTimeout ->
#             $('.accordion').accordion()
#         , 1000
#
#
#     Template.month_day_template.onCreated ->
#         @autorun => Meteor.subscribe 'reservation_by_day',Router.current().params.doc_id, @data
#     Template.month_day_template.helpers
#         product: -> Docs.findOne Router.current().params.doc_id
#         month: -> moment(Date.now()).format("MM")
#         day: -> parseInt @
#         year: -> moment(Date.now()).format("YY")
#
#         reservation_exists: ->
#             # console.log @
#             # console.log Template.currentData()
#             today = new Date()
#             this_days_number = parseInt @
#             date_output = moment(today).format("MM-#{this_days_number}-YY")
#             Docs.findOne
#                 model:'reservation'
#                 product_id:Router.current().params.doc_id
#                 date:date_output
#         reservation_count: ->
#             # console.log @
#             # console.log Template.currentData()
#             today = new Date()
#             this_days_number = parseInt @
#             date_output = moment(today).format("MM-#{this_days_number}-YY")
#             # console.log date_output
#             result = Docs.find(
#                 model:'reservation'
#                 product_id:Router.current().params.doc_id
#                 date:date_output
#                 ).count()
#             # console.log result
#             result
#
#
#     Template.month_day_template.events
#         'click .new_reservation': ->
#             console.log parseInt @
#             this_days_number = parseInt @
#             today = new Date()
#             console.log moment(today).format("MM-#{this_days_number}-YY")
#             date_output = moment(today).format("MM-#{this_days_number}-YY")
#             Docs.insert
#                 model:'reservation'
#                 product_id:Router.current().params.doc_id
#                 date:date_output
#
#
#     Template.rentals.helpers
#         rentals: ->
#             Docs.find
#                 model:'rental'
#                 product_id:Router.current().params.doc_id
#
#         reservations: ->
#             Docs.find {
#                 model:'reservation'
#                 product_id:Router.current().params.doc_id
#             },sort:
#                 date:-1
#                 hour:-1
#
#     Template.rental_view_calendar.helpers
#         month_day: ->
#             [1..30]
#         upcoming_days: ->
#             upcoming_days = []
#             now = new Date()
#             today = moment(now).format('dddd MMM Do')
#             # upcoming_days.push today
#             day_number = 0
#             for day in [0..6]
#                 day_number++
#                 moment_ob = moment(now).add(day, 'days')
#                 long_form = moment(now).add(day, 'days').format('ddd MMM Do')
#                 upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
#             upcoming_days
#
#     Template.rentals.events
#         'click .rent': ->
#             new_id = Docs.insert
#                 model:'rental'
#                 product_id:Router.current().params.doc_id
#
#     Template.upcoming_day.onCreated ->
#         # console.log @data.data
#         # @autorun => Meteor.subscribe 'reservation_slot', @data.data
#         # @autorun => Meteor.subscribe 'reservation_slot', @data.data
#         # @autorun -> Meteor.subscribe 'model_docs', 'reservation_slot'
#         # @autorun -> Meteor.subscribe 'model_docs', 'reservation'
#     Template.upcoming_day.helpers
#         product: ->
#             Docs.findOne Router.current().params.doc_id
#         print_this: ->
#             console.log @data.moment_ob
#         month: ->
#             moment(@data.moment_ob).format("M")
#         day: ->
#             moment(@data.moment_ob).format("D")
#         year: ->
#             moment(@data.moment_ob).format("YY")
#
#         is_product_author: ->
#             product = Template.parentData(2)
#             if product._author_id is Meteor.userId() then true else false
#         reservation_slot_exists: ->
#             # console.log moment(@data.moment_ob).format('MM-DD-YY')
#             # @moment_ob.format('dddd MMM Do')
#             product = Template.parentData(2)
#             console.log product
#             Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#                 product_id: product._id
#
#         reservation_slot: ->
#             # console.log @
#             # console.log Template.parentData(2)
#             product = Template.parentData(2)
#             # console.log moment(@data.moment_ob).format('MM-DD-YY')
#             # @moment_ob.format('dddd MMM Do')
#             # console.log product
#             Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#                 product_id: product._id
#
#     Template.upcoming_day.events
#         'click .new_slot': ->
#             # moment_ob = @valueOf()
#             # console.log @valueOf()
#             # console.log @
#             moment_ob = Template.parentData(1).moment_ob
#             console.log moment_ob
#             product = Template.parentData(2)
#             console.log moment(moment_ob).format('MM-DD-YY')
#             #
#             Docs.insert
#                 model:'reservation_slot'
#                 product_id: product._id
#                 date:moment_ob.format('MM-DD-YY')
#
#
#     Template.reservation_slot_template.helpers
#         slot: ->
#             # console.log @
#             product = Template.parentData(2)
#             Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#                 # product_id: product._id
#         need_price: ->
#             console.log @
#             slot = Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#             console.log @slot
#         reservation: ->
#             # console.log @
#             # console.log Template.parentData(2)
#             slot = Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#
#             found_reservation = Docs.findOne
#                 model:'reservation'
#                 date:@data.moment_ob.format('MM-DD-YY')
#                 parent_slot:slot._id
#             console.log found_reservation
#             found_reservation
#     Template.reservation_slot_template.events
#         'click .rent_item': ->
#             # console.log Template.parentData(2)
#             # console.log @
#             product = Docs.findOne Router.current().params.doc_id
#             # console.log product
#             slot = Docs.findOne
#                 model:'reservation_slot'
#                 date:@data.moment_ob.format('MM-DD-YY')
#             console.log slot
#             Docs.insert
#                 model:'reservation'
#                 parent_slot: slot._id
#                 date:@data.moment_ob.format('MM-DD-YY')
#                 product_id: product._id
#     # chips placeholder
#     # check weater pressure at chips place with pressure gauge on faucet
#
#     Template.kiosk_rental_view.events
#         'click .log_rental_view': ->
#             Docs.update @_id,
#                 $inc: views: 1
#
#     Template.rental.events
#         'click .delete_rental': ->
#             Docs.remove @_id
#         'click .calculate_diff': ->
#             product = Template.parentData()
#             console.log product
#             moment_a = moment @start_datetime
#             moment_b = moment @end_datetime
#             rental_hours = -1*moment_a.diff(moment_b,'hours')
#             rental_days = -1*moment_a.diff(moment_b,'days')
#             hourly_rental_price = rental_hours*product.hourly_rate
#             daily_rental_price = rental_days*product.daily_rate
#             Docs.update @_id,
#                 $set:
#                     'rental_hours':rental_hours
#                     'rental_days':rental_days
#                     hourly_rental_price:hourly_rental_price
#                     daily_rental_price:daily_rental_price
#
#
#     Template.rental_status.events
#         'click .new_reservation': (e,t)->
#             console.log @
#             new_reservation_id = Docs.insert
#                 model:'reservation'
#                 rental_id: @_id
#             Router.go "/new_reservation/#{new_reservation_id}"
#
#
#     Template.rental_view_transactions.onCreated ->
#         @autorun -> Meteor.subscribe 'rental_transactions', Template.currentData()
#     Template.rental_view_transactions.helpers
#         transactions: ->
#             Docs.find
#                 model:'transaction'
#
#
#
#     Template.rental_view_reservations.onCreated ->
#         console.log @
#         @autorun -> Meteor.subscribe 'rental_reservations', Template.currentData()
#     Template.rental_view_reservations.helpers
#         reservations: ->
#             Docs.find
#                 model:'reservation'
#
#
#
#
# if Meteor.isServer
#     Meteor.publish 'rental_transactions', (rental)->
#         console.log rental
#         Docs.find
#             model:'transactions'
#             rental_id: rental._id
#
#     Meteor.publish 'rental_reservations', (rental)->
#         console.log rental
#         Docs.find
#             model:'reservation'
#             rental_id: rental._id
#
#     Meteor.publish 'rentals', (product_id)->
#         Docs.find
#             model:'rental'
#             product_id:product_id
#
#     Meteor.publish 'reservation_by_day', (product_id, month_day)->
#         console.log month_day
#         console.log product_id
#         reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
#         # for reservation in reservations
#             # console.log 'id', reservation._id
#             # console.log reservation.paid_amount
#         Docs.find
#             model:'reservation'
#             product_id:product_id
#
#     Meteor.publish 'reservation_slot', (moment_ob)->
#         rentals_return = []
#         # for day in [0..6]
#         #     day_number++
#         #     # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
#         #     date_stripg =  moment(now).add(day, 'days').format('YYYY-MM-DD')
#         #     console.log date_stripg
#         #     rentals.return.push date_stripg
#         rentals_return
#
#         # data.long_form
#         # Docs.find
#         #     model:'reservation_slot'
