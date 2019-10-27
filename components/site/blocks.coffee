if Meteor.isClient
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.comments.onCreated ->
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        else
            parent = Docs.findOne Template.parentData()._id
        if parent
            @autorun => Meteor.subscribe 'children', 'comment', parent._id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            Docs.find
                parent_id:parent._id
                model:'comment'
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id

    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()
        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()

    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @


    Template.voting_small.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @



    Template.doc_card.onCreated ->
        @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
    Template.doc_card.helpers
        doc: ->
            Docs.findOne
                _id:Template.currentData().doc_id





    Template.call_watson.events
        'click .autotag': ->
            doc = Docs.findOne Router.current().params.doc_id
            console.log doc
            console.log @

            Meteor.call 'call_watson', doc._id, @key, @mode

    Template.voting_full.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @




    Template.role_editor.onCreated ->
        @autorun => Meteor.subscribe 'model', 'role'



    Template.user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.user_card.helpers
        user: -> Meteor.users.findOne username:@valueOf()


    Template.small_horizontal_user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.small_horizontal_user_card.helpers
        user: -> Meteor.users.findOne username:@valueOf()



    Template.big_user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.big_user_card.helpers
        user: -> Meteor.users.findOne username:@valueOf()




    Template.username_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.username_info.events
        'click .goto_profile': ->
            user = Meteor.users.findOne username:@valueOf()
            Router.go "/user/#{user.username}/"
    Template.username_info.helpers
        user: -> Meteor.users.findOne username:@valueOf()




    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info.helpers
        user: -> Meteor.users.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)





    Template.user_list_info.onCreated ->
        @autorun => Meteor.subscribe 'user', @data

    Template.user_list_info.helpers
        user: ->
            console.log @
            Meteor.users.findOne @valueOf()



    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key
    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
                Docs.update parent._id,
                    $pull:"#{@key}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@key}":Meteor.userId()
    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Meteor.user()
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Meteor.users.find _id:$in:parent["#{@key}"]




    Template.viewing.events
        'click .mark_read': (e,t)->
            Docs.update @_id,
                $inc:views:1
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @author_id
                        readers.push Meteor.users.findOne reader_id
            readers



    Template.lease_expiration_check.helpers
        lease_expiring: ->
            if @expiration_date
                # console.log @expiration_date
                today = moment(Date.now())
                expiration_moment = moment(@expiration_date)
                # diff = today-@expiration_date
                # console.log diff
                # console.log moment(@expiration_date).subtract(30, 'd').calendar()
                # console.log moment(@expiration_date).fromNow()
                # console.log moment(@expiration_date).calendar()
                expiration_moment.from(today)
                # date1_ms = @expiration_date.getTime()
                # date2_ms = today.getTime()
                #
                # # // Calculate the difference in milliseconds
                # difference_ms = Math.abs(date1_ms - date2_ms)
                #
                # # // Convert back to days and return
                # console.log Math.round(difference_ms/ONE_DAY)


                # minute_difference = diff/1000/60
                # if minute_difference>60
                    # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})







    Template.email_validation_check.events
        'click .send_verification': ->
            console.log @
            if confirm 'send verification email?'
                Meteor.call 'verify_email', @_id, ->
                    alert 'verification email sent'
        'click .toggle_email_verified': ->
            console.log @emails[0].verified
            if @emails[0]
                Meteor.users.update @_id,
                    $set:"emails.0.verified":true


    Template.add_button.onCreated ->
        # console.log @
        Meteor.subscribe 'model_from_slug', @data.model
    Template.add_button.helpers
        model: ->
            data = Template.currentData()
            Docs.findOne
                model: 'model'
                slug: data.model
    Template.add_button.events
        'click .add': ->
            new_id = Docs.insert
                model: @model
            Router.go "/m/#{@model}/#{new_id}/edit"


    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000


    Template.add_model_button.events
        'click .add': ->
            new_id = Docs.insert model: @model
            Router.go "/edit/#{new_id}"

    Template.view_user_button.events
        'click .view_user': ->
            Router.go "/user/#{username}"

    Template.kiosk_send_message.onCreated ->
        Session.set('sending_message',false)
        # @sending_message = new ReactiveVar false
        Session.set('sending_message_id', '')
    Template.sending_kiosk_message.onCreated ->
        @autorun => Meteor.subscribe 'doc', Session.get('sending_message_id')
        @autorun => Meteor.subscribe 'type', 'kiosk_message'

    Template.kiosk_send_message.events
        'click .create_message': (e,t)->
            # t.sending_message.set true
            Session.set('sending_message', true)
            # console.log @
            new_message_id = Docs.insert
                model:'message'
                type:'kiosk_message'
                parent_id: @_id
            Session.set('sending_message_id',new_message_id)
            # t.sending_message_id.set new_message_id

    Template.sending_kiosk_message.events
        'click .cancel_message': (e,t)->
            #     # t.sending_message.set false
            # console.log @
            # console.log Session.get('sending_message_id')
            # console.log Session.get('sending_message_id')
            # console.log @
            Docs.remove Session.get('sending_message_id')
            Session.set 'sending_message', null
            Session.set 'sending_message_id', null
        'click .send_message': ->
            console.log @
            Meteor.call 'send_kiosk_message', @, (err,res)->
                alert 'kiosk message sent'
                Session.set 'sending_message', null
                Session.set 'sending_message_id', null

    Template.kiosk_send_message.helpers
        sending_message: ->
            Session.get('sending_message')
            # Template.instance().sending_message.get()
    Template.sending_kiosk_message.helpers
        sending_message_doc: ->
            Docs.findOne
                type:'kiosk_message'
            # Docs.findOne Session.get('sending_message_id')
            # Docs.findOne Template.instance().sending_message_id.get()



    Template.suggestion_box.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'suggestion'
    Template.suggestion_box.events
        'click .add_suggestion': (e,t)->
            new_suggestion_id =
                Docs.insert
                    model:'suggestion'
            Session.set 'current_suggestion_id', new_suggestion_id
            $('.ui.modal').modal('show')

    Template.suggestion_box.helpers
        editing_suggestion: ->
            Docs.findOne Session.get('current_suggestion_id')
        public_suggestions: ->
            Docs.find
                model:'suggestion'
                public:true

    Template.user_array_element_toggle.helpers
        user_array_element_toggle_class: ->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"] and @value in @user["#{@key}"] then 'active' else ''
    Template.user_array_element_toggle.events
        'click .toggle_element': (e,t)->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"]
                if @value in @user["#{@key}"]
                    Meteor.users.update @user._id,
                        $pull: "#{@key}":@value
                else
                    Meteor.users.update @user._id,
                        $addToSet: "#{@key}":@value
            else
                Meteor.users.update @user._id,
                    $addToSet: "#{@key}":@value


    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users



    Template.user_array_list.onCreated ->
        @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users




    Template.key_value_edit.events
        'click .set_key_value': ->
            parent = Template.parentData()
            Docs.update parent._id,
                $set: "#{@key}": @value

    Template.key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            if parent["#{@key}"] is @value then 'green' else ''











if Meteor.isServer
    Meteor.methods
        'send_kiosk_message': (message)->
            parent = Docs.findOne message.parent._id
            Docs.update message._id,
                $set:
                    sent: true
                    sent_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'kiosk_message_sent'
                text:"kiosk message sent"


    Meteor.publish 'rules_signed_username', (username)->
        Docs.find
            model:'rules_and_regs_signing'
            student:username
            # agree:true

    Meteor.publish 'type', (type)->
        Docs.find
            type:type

    Meteor.publish 'user_guidelines_username', (username)->
        Docs.find
            model:'user_guidelines_signing'
            # student:username
            # agree:true

    Meteor.publish 'guests', ()->
        Meteor.users.find
            roles:$in:['guest']


    Meteor.publish 'children', (model, parent_id, limit)->
        # console.log model
        # console.log parent_id
        limit = if limit then limit else 10
        Docs.find {
            model:model
            parent_id:parent_id
        }, limit:limit
