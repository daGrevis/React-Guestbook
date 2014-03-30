Dom = React.DOM
$.postJSON = (url, data, callback) ->
    $.post url, data, callback, "json"

converter = new Showdown.converter()

Comment = React.createClass
    displayName: "Comment"

    render: ->
        content = converter.makeHtml @props.content

        (Dom.li className: "media",
            (Dom.a className: "pull-left",
                (Dom.img className: "media-object img-rounded", src: "http://avatars.io/email/#{ @props.email }?size=medium", width: 64, height: 64)),
            (Dom.div className: "media-body",
                (Dom.h4 className: "media-heading", @props.name),
                (Dom.span dangerouslySetInnerHTML: {__html: content})))

CommentList = React.createClass
    displayName: "CommentList"

    render: ->
        commentNodes = $.map @props.data, (comment) ->
            Comment
                name: comment.name
                email: comment.email
                content: comment.content

        Dom.ul className: "media-list", commentNodes

CommentForm = React.createClass
    displayName: "CommentForm"

    getInitialState: ->
        name: ""
        email: ""
        content: ""

    handleSubmit: (event) ->
        event.preventDefault()

        if not (@state.name and @state.email and @state.content)
            return false

        @props.onCommentSubmit
            name: @state.name
            email: @state.email
            content: @state.content

        @setState @getInitialState()

    updateStateForFormElement: (event) ->
        target = event.target
        state = @state
        state[target.name] = target.value
        @setState state

    render: ->
        (Dom.div {},
            (Dom.h2 {}, "Check In"),
            (Dom.form onSubmit: @handleSubmit,
                (Dom.div className: "form-group",
                    (Dom.input type: "text", className: "form-control", placeholder: "Your Name", name: "name", value: @state.name, onChange: @updateStateForFormElement)),
                (Dom.div className: "form-group",
                    (Dom.input type: "text", className: "form-control", placeholder: "Your Email", name: "email", value: @state.email, onChange: @updateStateForFormElement)),
                (Dom.div className: "form-group",
                    (Dom.textarea rows: 4, className: "form-control", placeholder: "Your Message", name: "content", value: @state.content, onChange: @updateStateForFormElement)),
                (Dom.button type: "submit", className: "btn btn-success",
                    "Check In")))

CommentBox = React.createClass
    displayName: "CommentBox"

    getInitialState: ->
        data: []

    loadCommentsFromServer: ->
        $.getJSON @props.url, (data) =>
            @setState data: data.comments

    componentWillMount: ->
        @loadCommentsFromServer()
        setInterval @loadCommentsFromServer, @props.pollInterval

    handleCommentSubmit: (comment) ->
        comments = @state.data
        newComments = comments.concat [comment]
        @.setState data: newComments

        $.postJSON @props.url, comment, (data) =>
            @setState data: data.comments

    render: ->
        (Dom.div className: "commentBox",
            (Dom.h1 {}, "Guestbook"),
            (CommentList data: @state.data)
            (CommentForm onCommentSubmit: @handleCommentSubmit))

React.renderComponent CommentBox(url: "/comments/", pollInterval: 10 * 1000), $("#react").get 0
