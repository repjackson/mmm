if Meteor.isClient
    Template.student_item.onCreated ->
        @autorun => Meteor.subscribe 'user_by_id', @data
        @editing_student = new ReactiveVar false
    Template.student_item.helpers
        student: -> Meteor.users.findOne Template.currentData()
        editing_student: ->
            # console.log @
            Template.instance().editing_student.get() is @_id
    Template.student_item.events
        'click .remove_student': ->
            if confirm "Remove #{@first_name} #{@last_name} from classroom?"
                student = Docs.findOne Router.current().params.doc_id
                Docs.update student._id,
                    $pull:student_ids:@_id

        'click .edit_student': ->
            Template.instance().editing_student.set(@_id)
        'click .save_student': (e,t)->
            Template.instance().editing_student.set(null)
            first_name = $('.first_name').val().trim()
            last_name = $('.last_name').val().trim()
            console.log @
            Meteor.users.update @_id,
                $set:
                    first_name: first_name
                    last_name: last_name



    Template.student_selector.onCreated ->
        Session.set('last_name',null)
        Session.set('first_name',null)
        @student_results = new ReactiveVar
        @autorun => Meteor.subscribe 'student_ids', Router.current().params.doc_id
    Template.student_selector.helpers
        last_name: -> Session.get('last_name')
        first_name: -> Session.get('first_name')
        add_student_button_class: ->
            if Session.get('first_name') and Session.get('last_name') then 'green' else 'disabled'
        student_results: -> Template.instance().student_results.get()
        selected_students: ->
            student = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id:$in:student.student_ids
    Template.student_selector.events
        'click .clear_results': (e,t)->
            t.student_results.set null
        'keyup #first_name': (e,t)->
            first_name = $('#first_name').val().trim()
            Session.set "first_name", first_name
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            Session.set "last_name", last_name
            if e.which is 13
                Meteor.call 'add_student', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        console.log err
                    else
                        Docs.update Router.current().params.doc_id,
                            $addToSet:student_ids:res
                        $('#first_name').val('')
                        $('#last_name').val('')
                        Session.set "last_name", null
                        Session.set "first_name", null
                        $('#first_name').focus()    

        'click .create_student': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            Session.set "last_name", last_name
            Meteor.call 'add_student', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                if err
                    console.log err
                else
                    Docs.update Router.current().params.doc_id,
                        $addToSet:student_ids:res
                    $('#first_name').val('')
                    $('#last_name').val('')
                    Session.set "last_name", null
                    Session.set "first_name", null
                    $('#first_name').focus()
        'keyup #student_input': (e,t)->
            search_value = $(e.currentTarget).closest('#student_input').val().trim()
            if e.which is 8
                t.student_results.set null
            else if search_value and search_value.length > 1
                Meteor.call 'lookup_student', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.student_results.set res
        'click .select_student': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update Router.current().params.doc_id,
                $addToSet:student_ids:@_id
            t.student_results.set null
            $('#student_input').val ''
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()


if Meteor.isServer
    Meteor.publish 'student_ids', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id:$in:classroom.student_ids

    Meteor.publish 'user_by_id', (user_id)->
        Meteor.users.find user_id

    Meteor.methods
        lookup_student: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['students']
                },{limit:10}).fetch()
