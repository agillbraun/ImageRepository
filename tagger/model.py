from typing import Any
from dataclasses import dataclass
from common import Label
from enum import Enum
from box import Box
import torch


#
# Model Output Objects
#


class ResultType(Enum):
  BOX = 0
  NET = 1


@dataclass
class NetResult:
  """
  Represents the output of a neural net.
  """
  # the object class code
  cls: int
  # the prediction confidence
  conf: float
  # the associated label
  label: Label


@dataclass
class BoxResult(NetResult):
  """
  Represents the output of a neural net with a bounding box.
  """
  # the object bounding box
  bbox: Box


#
# Model Loading
#

def load_yolo() -> Any:
  model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
  # model.eval()
  return model


def load_mobilenet() -> Any:
  model = torch.hub.load('pytorch/vision:v0.6.0', 'mobilenet_v2', pretrained=True)
  model.eval()
  return model


def load_shufflenet() -> Any:
  model = torch.hub.load('pytorch/vision:v0.6.0', 'shufflenet_v2_x1_0', pretrained=True)
  model.eval()
  return model


yolo = load_yolo()
mobilenet = load_mobilenet()
shufflenet = load_shufflenet()
