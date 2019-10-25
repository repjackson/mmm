if Meteor.isClient
    Template.member_item.onCreated ->
        @autorun => Meteor.subscribe 'user_by_id', @data
    Template.member_item.helpers
        member: -> Meteor.users.findOne Template.currentData()

    Template.member_selector.onCreated ->
        @member_results = new ReactiveVar
        @autorun => Meteor.subscribe 'member_ids', Router.current().params.doc_id
    Template.member_selector.helpers
        member_results: -> Template.instance().member_results.get()
        selected_members: ->
            group = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id:$in:group.member_ids
    Template.member_selector.events
        'click .clear_results': (e,t)->
            t.member_results.set null
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_member', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        alert err
                    else
                        Docs.update Router.current().params.doc_id,
                            $addToSet:member_ids:res
                        $('#first_name').val('')
                        $('#last_name').val('')
        'keyup #member_input': (e,t)->
            search_value = $(e.currentTarget).closest('#member_input').val().trim()
            if e.which is 8
                t.member_results.set null
            else if search_value and search_value.length > 1
                Meteor.call 'lookup_member', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.member_results.set res
        'click .select_member': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update Router.current().params.doc_id,
                $addToSet:member_ids:@_id
            t.member_results.set null
            $('#member_input').val ''
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()

        'click .remove_member': ->
            if confirm "remove #{first_name} #{last_name} from group?"
                group = Docs.findOne Router.current().params.doc_id
                Docs.update group._id,
                    $pull:member_ids:@_id


if Meteor.isServer
    Meteor.publish 'member_ids', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find
            _id:$in:group.member_ids

    Meteor.publish 'user_by_id', (user_id)->
        Meteor.users.find user_id

    Meteor.methods
        lookup_member: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['members']
                },{limit:10}).fetch()
