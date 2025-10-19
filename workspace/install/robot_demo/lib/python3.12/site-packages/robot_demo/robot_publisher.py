#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import PoseStamped
from visualization_msgs.msg import Marker
import math

class RobotPublisher(Node):
    def __init__(self):
        super().__init__('robot_publisher')
        self.pose_pub = self.create_publisher(PoseStamped, 'robot_pose', 10)
        self.marker_pub = self.create_publisher(Marker, 'robot_marker', 10)
        self.timer = self.create_timer(0.1, self.publish_data)
        self.counter = 0.0
        self.get_logger().info('Robot Publisher Started!')

    def publish_data(self):
        pose = PoseStamped()
        pose.header.frame_id = "map"
        pose.header.stamp = self.get_clock().now().to_msg()
        pose.pose.position.x = math.cos(self.counter) * 3.0
        pose.pose.position.y = math.sin(self.counter) * 3.0
        pose.pose.position.z = 0.0
        pose.pose.orientation.w = 1.0
        
        self.pose_pub.publish(pose)
        
        marker = Marker()
        marker.header = pose.header
        marker.ns = "robot"
        marker.id = 0
        marker.type = Marker.CUBE
        marker.action = Marker.ADD
        marker.pose = pose.pose
        marker.scale.x = 0.5
        marker.scale.y = 0.5
        marker.scale.z = 0.5
        marker.color.r = 1.0
        marker.color.g = 0.0
        marker.color.b = 0.0
        marker.color.a = 1.0
        
        self.marker_pub.publish(marker)
        self.counter += 0.05

def main(args=None):
    rclpy.init(args=args)
    node = RobotPublisher()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()