if Meteor.isClient
    Router.route '/build_group/:doc_id', (->
        @layout 'no_footer_layout'
        @render 'build_group_finance'
        ), name:'build_group_home'
    Router.route '/build_group/:doc_id/finance', (->
        @layout 'no_footer_layout'
        @render 'build_group_finance'
        ), name:'build_group_finance'
    Router.route '/build_group/:doc_id/info', (->
        @layout 'no_footer_layout'
        @render 'build_group_info'
        ), name:'build_group_info'
    Router.route '/build_group/:doc_id/members', (->
        @layout 'no_footer_layout'
        @render 'build_group_members'
        ), name:'build_group_members'

    Template.build_group_info.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.build_group_info.events
    Template.build_group_info.helpers

    Template.build_group_finance.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.build_group_finance.events
    Template.build_group_finance.helpers

    Template.build_group_members.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_members_by_group_id', Router.current().params.doc_id
    Template.build_group_members.events
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_member', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        alert err
                    else
                        $('#first_name').val('')
                        $('#last_name').val('')
        'click .remove_member': ->
            if confirm "remove #{first_name} #{last_name}?"
                Meteor.users.remove @_id


    Template.build_group_members.helpers
        group_members: ->
            Meteor.users.find
                roles:$in:['member']
                group_id:Router.current().params.doc_id




if Meteor.isServer
    Meteor.publish 'group_members_by_group_id', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find
            roles:$in:['member']
            group_id:group_id

    Meteor.methods
        add_member: (first_name, last_name, group_id)->
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"

            options = {}
            options.username = username

            res= Accounts.createUser options
            if res
                Meteor.users.update res,
                    $set:
                        first_name: first_name
                        last_name: last_name
                        group_id: group_id
                        added_by_username: Meteor.user().username
                        added_by_user_id: Meteor.userId()
                        roles: ['member']
                return res
            else
                Throw.new Meteor.Error 'err creating user'
