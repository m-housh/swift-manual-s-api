import FirstPartyMocks
import Html
import Models

func renderCooling(
  _ route: ServerRoute.Documentation.Route.Interpolation.Cooling
) -> any Renderable {
  switch route {
  case .oneWayIndoor:
    return OneWayIndoorView()
  case .oneWayOutdoor:
    return OneWayOutdoorView()
  case .noInterpolation:
    return NoInterpolationView()
  case .twoWay:
    return TwoWayView()
  }
}

private struct OneWayIndoorView: Renderable {
  let title: String = ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayIndoor.text

  let mainDescription = """
    This route is used for one way interpolation of manufacturer's capacities at indoor design conditions.
    """
  let exampleText = """
    My summer outdoor design is 95° dry-bulb and my indoor design is 63° wet-bulb
    """
  let exampleSubTexts = [
    "The manufacturer's published outdoor data is equal to the outdoor design conditions.",
    """
      The manufacturer's published indoor data is 67° and 62° wet-bulb, so interpolation is needed to
      calculate the capacity at 63° wet-bulb.
    """,
  ]

  let inputDescription = card(body: [
    ("aboveDesign", "The manufacturer's capacity above the indoor design conditions."),
    ("belowDesign", "The manufacturer's capacity below the indoor design conditions."),
    ("designInfo", "The design information for the project."),
    ("houseLoad", "The house load for the project at design conditions."),
    ("manufacturerAdjustments", "Optional adjustments multipliers to the manufacturer's capacity."),
    ("systemType", "The system type for the interpolation."),
  ])

  func content() async throws -> Node {
    try await InterpolationView(
      description: .init(
        mainDescription: mainDescription,
        exampleText: exampleText,
        exampleSubTexts: exampleSubTexts
      ),
      title: title,
      route: .mock(route: .cooling(route: .oneWayIndoor(.mock))),
      inputDescription: inputDescription,
      failingJson: .mock(route: .cooling(route: .oneWayIndoor(.zero)))
    ).content()
  }
}

private struct OneWayOutdoorView: Renderable {
  let title: String = ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayOutdoor.text

  let mainDescription = """
    This route is used for one way interpolation of manufacturer's capacities at outdoor design conditions.
    """
  let exampleText = """
    My summer outdoor design is 92° dry-bulb and my indoor design is 63° wet-bulb
    """
  let exampleSubTexts = [
    "The manufacturer's published indoor data is equal to the indoor design conditions.",
    """
      The manufacturer's published outdoor data is 85° and 95° dry-bulb, so interpolation is needed to
      calculate the capacity at 92° dry-bulb.
    """,

  ]

  let inputDescription = card(body: [
    ("aboveDesign", "The manufacturer's capacity above the outdoor design conditions."),
    ("belowDesign", "The manufacturer's capacity below the outdoor design conditions."),
    ("designInfo", "The design information for the project."),
    ("houseLoad", "The house load for the project at design conditions."),
    ("manufacturerAdjustments", "Optional adjustments multipliers to the manufacturer's capacity."),
    ("systemType", "The system type for the interpolation."),
  ])

  func content() async throws -> Node {
    try await InterpolationView(
      description: .init(
        mainDescription: mainDescription,
        exampleText: exampleText,
        exampleSubTexts: exampleSubTexts
      ),
      title: title,
      route: .mock(route: .cooling(route: .oneWayOutdoor(.mock))),
      inputDescription: inputDescription,
      failingJson: .mock(route: .cooling(route: .oneWayOutdoor(.zero)))
    ).content()
  }
}

private struct NoInterpolationView: Renderable {
  let title: String = ServerRoute.Documentation.Route.Interpolation.Cooling.noInterpolation.text

  let mainDescription = """
    This route is used for no interpolation of manufacturer's capacities at the design conditions.
    """
  let exampleText = """
    My summer outdoor design is 90° dry-bulb and my indoor design is 63° wet-bulb
    """
  let exampleSubTexts = [
    "The manufacturer's published indoor data is equal to the indoor design conditions.",
    """
      The manufacturer's published outdoor data is equal to the outdoor design conditions.
    """,

  ]

  let inputDescription = card(body: [
    ("capacity", "The manufacturer's capacity at the design indoor and outdoor conditions."),
    ("designInfo", "The design information for the project."),
    ("houseLoad", "The house load for the project at design conditions."),
    ("manufacturerAdjustments", "Optional adjustments multipliers to the manufacturer's capacity."),
    ("systemType", "The system type for the interpolation."),
  ])

  func content() async throws -> Node {
    try await InterpolationView(
      description: .init(
        mainDescription: mainDescription,
        exampleText: exampleText,
        exampleSubTexts: exampleSubTexts
      ),
      title: title,
      route: .mock(route: .cooling(route: .noInterpolation(.mock))),
      inputDescription: inputDescription,
      failingJson: .mock(route: .cooling(route: .noInterpolation(.zero)))
    ).content()
  }
}

private struct TwoWayView: Renderable {
  
  let title: String = ServerRoute.Documentation.Route.Interpolation.Cooling.twoWay.text

  let mainDescription = """
    This route is used for two way interpolation of manufacturer's capacities at the indoor and outdoor design conditions.
    """
  let exampleText = """
    My summer outdoor design is 92° dry-bulb and my indoor design is 63° wet-bulb
    """
  let exampleSubTexts = [
    """
    The manufacturer's published indoor data is 67° and 62° wet-bulb, so interpolation is needed to calculate the
    capacity at 63° wet-bulb
    """,
    """
    The manufacturer's published outdoor data is 85° and 95° dry-bulb, so interpolation is needed to calculate the
    capacity at 92° dry-bulb.
    """,

  ]

  let inputDescription = card(body: [
    ("aboveDesign", "The manufacturer's capacity above the indoor and outdoor design conditions."),
    ("belowDesign", "The manufacturer's capacity below the indoor and outdoor design conditions."),
    ("designInfo", "The design information for the project."),
    ("houseLoad", "The house load for the project at design conditions."),
    ("manufacturerAdjustments", "Optional adjustments multipliers to the manufacturer's capacity."),
    ("systemType", "The system type for the interpolation."),
  ])

  func content() async throws -> Node {
    try await InterpolationView(
      description: .init(
        mainDescription: mainDescription,
        exampleText: exampleText,
        exampleSubTexts: exampleSubTexts
      ),
      title: title,
      route: .mock(route: .cooling(route: .twoWay(.mock))),
      inputDescription: inputDescription,
      failingJson: .mock(route: .cooling(route: .twoWay(.zero)))
    ).content()
  }
}

private struct InterpolationView: Renderable {
  let description: Description
  let title: String
  let route: ServerRoute.Api.Route.Interpolation
  let inputDescription: Node
  let failingJson: ServerRoute.Api.Route.Interpolation
  
  init(
    description: Description,
    title: String,
    route: ServerRoute.Api.Route.Interpolation,
    inputDescription: Node,
    failingJson: ServerRoute.Api.Route.Interpolation
  ) {
    self.description = description
    self.title = title
    self.route = route
    self.inputDescription = inputDescription
    self.failingJson = failingJson
  }

  struct Description {
    let mainDescription: String
    let exampleText: String
    let exampleSubTexts: [String]

    private var exampleUl: Node {
      exampleSubTexts.reduce(into: Node.ul(attributes: [.class(.margin(.bottom(0)))])) {
        ul, string in
        ul.append(
          ChildOf<Tag.Ul>.li(
            attributes: [.class("ms-4")],
            Node.text(string)
          ).rawValue
        )
      }
    }

    private var exampleNode: Node {
      .div(
        attributes: [.class(.card, .bg(.success, .subtle))],
        .div(
          attributes: [.class(.card(.body))],
          .h5(attributes: [.class(.card(.title))], .text("Example:")),
          .h6(
            attributes: [.class(.card(.subtitle), .margin(.bottom(3)), .text(.muted))],
            .text(exampleText)),
          exampleUl
        )
      )
    }

    var content: Node {
      container {
        [
          row(class: .padding(.top(2))) {
            .p(.text(mainDescription))
          },
          exampleNode,
        ]
      }
    }
  }

  func content() async throws -> Node {
    try await RouteView(
      json: route,
      route: .interpolate(route),
      title: title,
      description: description.content,
      inputDescription: inputDescription,
      failingJson: .interpolate(failingJson)
    ).content()
  }
}
