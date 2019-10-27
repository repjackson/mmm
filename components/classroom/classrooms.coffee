# if Meteor.isClient
#     Template.classrooms.onRendered ->
#     Template.classrooms.onCreated ->
#         # @autorun => Meteor.subscribe 'model_docs', 'classroom'
#         @autorun -> Meteor.subscribe('classroom_facet_docs',
#             selected_classroom_tags.array()
#             # Session.get('sort_key')
#         )
#
#     Template.classrooms.events
#         'click .add_classroom': ->
#             new_classroom = Docs.insert
#                 model:'classroom'
#                 teacher_id: Meteor.userId()
#             Router.go "/classroom/#{new_classroom}/edit"
#     Template.classrooms.helpers
#         classrooms: ->
#             Docs.find {
#                 model:'classroom'
#             }, sort: _timestamp: -1
#
#
#     # Template.my_classrooms.onRendered ->
#     # Template.my_classrooms.onCreated ->
#     #     @autorun => Meteor.subscribe 'my_classrooms'
#     #     @autorun => Meteor.subscribe 'model_docs', 'classroom'
#     # Template.my_classrooms.events
#     #     'click .add_classroom': ->
#     #         new_classroom = Docs.insert
#     #             model:'classroom'
#     #             teacher_id: Meteor.userId()
#     #         Router.go "/classroom/#{new_classroom}/edit"
#     # Template.my_classrooms.helpers
#     #     classrooms: ->
#     #         Docs.find {
#     #             model:'classroom'
#     #         }, sort: _timestamp: -1
#
#
#     Template.classroom_card_template.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
#     Template.classrooms.helpers
#
#
#
# if Meteor.isServer
#     Meteor.publish 'my_classrooms', ->
#         Docs.find
#             model:'classroom'
#             teacher_id:Meteor.userId()
