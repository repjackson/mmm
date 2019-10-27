if Meteor.isClient
    # Template.classroom_item.onCreated ->
    #     @autorun => Meteor.subscribe 'user_by_id', @data
    # Template.classroom_item.helpers
    #     classroom: -> Meteor.users.findOne Template.currentData()

    Template.student_selector.onCreated ->
        @classroom_results = new ReactiveVar
        @autorun => Meteor.subscribe 'classroom_ids', Router.current().params.doc_id
    Template.student_selector.helpers
        classroom_results: -> Template.instance().classroom_results.get()
        selected_classrooms: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id:$in:classroom.classroom_ids
    Template.student_selector.events
        'click .clear_results': (e,t)->
            t.classroom_results.set null
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_classroom', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        alert err
                    else
                        Docs.update Router.current().params.doc_id,
                            $addToSet:classroom_ids:res
                        $('#first_name').val('')
                        $('#last_name').val('')
        'keyup #classroom_input': (e,t)->
            search_value = $(e.currentTarget).closest('#classroom_input').val().trim()
            if e.which is 8
                t.classroom_results.set null
            else if search_value and search_value.length > 1
                Meteor.call 'lookup_classroom', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.classroom_results.set res
        'click .select_classroom': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update Router.current().params.doc_id,
                $addToSet:classroom_ids:@_id
            t.classroom_results.set null
            $('#classroom_input').val ''
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()

        'click .remove_classroom': ->
            if confirm "remove #{first_name} #{last_name} from classroom?"
                classroom = Docs.findOne Router.current().params.doc_id
                Docs.update classroom._id,
                    $pull:classroom_ids:@_id


if Meteor.isServer
    Meteor.publish 'classroom_ids', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id:$in:classroom.classroom_ids

    Meteor.publish 'user_by_id', (user_id)->
        Meteor.users.find user_id

    Meteor.methods
        lookup_classroom: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['classrooms']
                },{limit:10}).fetch()
